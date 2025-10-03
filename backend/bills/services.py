"""
Congress.gov API Service
Service for fetching federal legislative data from official Congress.gov API
"""

import requests
import logging
from datetime import datetime, timedelta
from typing import Dict, Optional
from django.conf import settings
from django.utils.dateparse import parse_datetime


logger = logging.getLogger(__name__)


class CongressAPI:
    """Congress.gov API client (official Library of Congress API)"""
    
    BASE_URL = "https://api.congress.gov/v3"
    
    def __init__(self, api_key: str = None):
        self.api_key = api_key or getattr(settings, 'CONGRESS_API_KEY', '')
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'PolicyLogs/1.0'
        })
    
    def _make_request(self, endpoint: str, params: Dict = None) -> Dict:
        """Make API request with error handling"""
        params = params or {}
        params.update({
            'api_key': self.api_key,
            'format': 'json'
        })
        
        url = f"{self.BASE_URL}/{endpoint}"
        
        try:
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"Congress API request failed: {e}")
            raise
    
    def get_recent_bills(self, congress: int = 118, limit: int = 20, offset: int = 0) -> Dict:
        """Get recent bills from Congress.gov API"""
        endpoint = f"bill/{congress}"
        params = {
            'limit': limit,
            'offset': offset,
            'sort': 'updateDate+desc'
        }
        return self._make_request(endpoint, params)
    
    def get_bill_details(self, congress: int, bill_type: str, bill_number: str) -> Dict:
        """Get detailed information about a specific bill"""
        endpoint = f"bill/{congress}/{bill_type}/{bill_number}"
        return self._make_request(endpoint)
    
    def get_bill_actions(self, congress: int, bill_type: str, bill_number: str) -> Dict:
        """Get actions for a specific bill"""
        endpoint = f"bill/{congress}/{bill_type}/{bill_number}/actions"
        return self._make_request(endpoint)
    
    def get_bill_cosponsors(self, congress: int, bill_type: str, bill_number: str) -> Dict:
        """Get cosponsors for a specific bill"""
        endpoint = f"bill/{congress}/{bill_type}/{bill_number}/cosponsors"
        return self._make_request(endpoint)


class BillSyncService:
    """Service for syncing bill data from APIs to database"""
    
    def __init__(self):
        self.api = CongressAPI()
    
    def sync_recent_bills(self, congress: int = 118, days_back: int = 7) -> Dict:
        """
        Sync recent bills from the last N days
        
        Returns:
            Dict with sync statistics
        """
        from .models import LegislativeBill, BillSubject, BillAction, BillCosponsor
        
        stats = {
            'bills_created': 0,
            'bills_updated': 0,
            'subjects_created': 0,
            'actions_created': 0,
            'cosponsors_created': 0,
            'errors': []
        }
        
        try:
            # Get recent bills from Congress.gov
            recent_bills = self.api.get_recent_bills(congress=congress, limit=250)
            
            for bill_data in recent_bills.get('bills', []):
                try:
                    bill, created = self._sync_bill(bill_data)
                    if created:
                        stats['bills_created'] += 1
                    else:
                        stats['bills_updated'] += 1
                        
                except Exception as e:
                    stats['errors'].append(f"Error syncing bill {bill_data.get('type', 'unknown')} {bill_data.get('number', 'unknown')}: {e}")
                    logger.error(f"Error syncing bill: {e}")
                    
        except Exception as e:
            stats['errors'].append(f"Error fetching bills from API: {e}")
            logger.error(f"Error fetching bills: {e}")
            
        return stats
    
    def _sync_bill(self, bill_data: Dict):
        """Sync a single bill from API data"""
        from .models import LegislativeBill
        
        # Extract bill identifiers
        congress = bill_data.get('congress', 118)
        bill_type = bill_data.get('type', '').lower()
        bill_number = bill_data.get('number', '')
        
        # Get or create bill
        bill, created = LegislativeBill.objects.get_or_create(
            congress_number=congress,
            bill_type=bill_type,
            bill_number=bill_number,
            defaults={
                'title': bill_data.get('title', ''),
                'congress_url': bill_data.get('url', ''),
                'latest_action': bill_data.get('latestAction', {}).get('text', ''),
            }
        )
        
        # Update bill fields
        bill.title = bill_data.get('title', bill.title)
        bill.congress_url = bill_data.get('url', bill.congress_url)
        
        # Parse latest action date
        latest_action = bill_data.get('latestAction', {})
        if latest_action:
            bill.latest_action = latest_action.get('text', '')
            action_date = latest_action.get('actionDate')
            if action_date:
                try:
                    # Convert date string to datetime
                    bill.latest_action_date = datetime.strptime(action_date, '%Y-%m-%d')
                except ValueError:
                    logger.warning(f"Could not parse action date: {action_date}")
        
        bill.save()
        return bill, created
