"""
Legislative Bill Tracking Models
Django models for integrating federal legislative data
"""

from django.db import models
from django.contrib.auth.models import User


class LegislativeBill(models.Model):
    """Federal bill information from Congress APIs"""
    
    CHAMBER_CHOICES = [
        ('house', 'House of Representatives'),
        ('senate', 'Senate'),
        ('joint', 'Joint'),
    ]
    
    BILL_TYPE_CHOICES = [
        ('hr', 'House Bill'),
        ('s', 'Senate Bill'),
        ('hjres', 'House Joint Resolution'),
        ('sjres', 'Senate Joint Resolution'),
        ('hconres', 'House Concurrent Resolution'),
        ('sconres', 'Senate Concurrent Resolution'),
        ('hres', 'House Simple Resolution'),
        ('sres', 'Senate Simple Resolution'),
    ]
    
    STATUS_CHOICES = [
        ('introduced', 'Introduced'),
        ('passed_house', 'Passed House'),
        ('passed_senate', 'Passed Senate'),
        ('enacted', 'Enacted'),
        ('vetoed', 'Vetoed'),
        ('dead', 'Dead/Failed'),
    ]
    
    # Basic bill identification
    congress_number = models.IntegerField(help_text="Congress session number (e.g., 118)")
    bill_type = models.CharField(max_length=10, choices=BILL_TYPE_CHOICES)
    bill_number = models.CharField(max_length=20, help_text="Bill number without type")
    chamber = models.CharField(max_length=10, choices=CHAMBER_CHOICES, blank=True)
    
    # Bill content
    title = models.TextField(help_text="Official bill title")
    short_title = models.CharField(max_length=500, blank=True)
    summary = models.TextField(blank=True)
    
    # Status and progress
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='introduced')
    latest_action = models.TextField(blank=True)
    latest_action_date = models.DateTimeField(null=True, blank=True)
    
    # Sponsor information
    sponsor_name = models.CharField(max_length=200, blank=True)
    sponsor_party = models.CharField(max_length=10, blank=True)
    sponsor_state = models.CharField(max_length=2, blank=True)
    sponsor_bioguide_id = models.CharField(max_length=10, blank=True)
    
    # External API references
    congress_url = models.URLField(blank=True)
    propublica_id = models.CharField(max_length=50, null=True, blank=True, unique=True)
    govtrack_id = models.CharField(max_length=50, blank=True)
    
    # Key dates
    introduced_date = models.DateTimeField(null=True, blank=True)
    house_passage_date = models.DateTimeField(null=True, blank=True)
    senate_passage_date = models.DateTimeField(null=True, blank=True)
    enacted_date = models.DateTimeField(null=True, blank=True)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_synced = models.DateTimeField(auto_now=True)
    
    # Connection to policy logs
    related_policies = models.ManyToManyField(
        'logs.PolicyLog', 
        blank=True,
        help_text="Policy logs that reference or are affected by this bill"
    )
    
    class Meta:
        ordering = ['-latest_action_date', '-introduced_date']
        unique_together = ['congress_number', 'bill_type', 'bill_number']
        
    def __str__(self):
        return f"{self.bill_type.upper()} {self.bill_number} - {self.title[:50]}"
        
    @property
    def bill_slug(self):
        """Generate URL-friendly bill identifier"""
        return f"{self.congress_number}-{self.bill_type}-{self.bill_number}"


class BillSubject(models.Model):
    """Legislative policy areas and subjects for bills"""
    
    bill = models.ForeignKey(LegislativeBill, on_delete=models.CASCADE, related_name='subjects')
    name = models.CharField(max_length=200)
    policy_area = models.CharField(max_length=200, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ['bill', 'name']
        
    def __str__(self):
        return f"{self.name} ({self.bill.bill_type.upper()} {self.bill.bill_number})"


class BillAction(models.Model):
    """Legislative actions taken on bills"""
    
    ACTION_TYPE_CHOICES = [
        ('introduced', 'Introduced'),
        ('referred', 'Referred to Committee'),
        ('reported', 'Reported by Committee'),
        ('passed', 'Passed Chamber'),
        ('failed', 'Failed'),
        ('amended', 'Amended'),
        ('signed', 'Signed by President'),
        ('vetoed', 'Vetoed'),
        ('override', 'Veto Override'),
    ]
    
    bill = models.ForeignKey(LegislativeBill, on_delete=models.CASCADE, related_name='actions')
    action_type = models.CharField(max_length=20, choices=ACTION_TYPE_CHOICES)
    action_date = models.DateTimeField()
    description = models.TextField()
    chamber = models.CharField(max_length=10, choices=LegislativeBill.CHAMBER_CHOICES, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-action_date']
        
    def __str__(self):
        return f"{self.action_date.date()} - {self.description[:50]}"


class BillCosponsor(models.Model):
    """Cosponsors of legislative bills"""
    
    bill = models.ForeignKey(LegislativeBill, on_delete=models.CASCADE, related_name='cosponsors')
    name = models.CharField(max_length=200)
    party = models.CharField(max_length=10, blank=True)
    state = models.CharField(max_length=2, blank=True)
    bioguide_id = models.CharField(max_length=10, blank=True)
    sponsored_date = models.DateTimeField(null=True, blank=True)
    withdrawn_date = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ['bill', 'bioguide_id']
        
    def __str__(self):
        return f"{self.name} ({self.party}-{self.state})"


class CongressMember(models.Model):
    """Information about Congress members"""
    
    bioguide_id = models.CharField(max_length=10, unique=True)
    name = models.CharField(max_length=200)
    party = models.CharField(max_length=10)
    state = models.CharField(max_length=2)
    district = models.CharField(max_length=3, blank=True)  # For House members
    chamber = models.CharField(max_length=10, choices=LegislativeBill.CHAMBER_CHOICES)
    
    # Terms
    current_term_start = models.DateField(null=True, blank=True)
    current_term_end = models.DateField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['state', 'name']
        
    def __str__(self):
        return f"{self.name} ({self.party}-{self.state})"


class LegislativeAlert(models.Model):
    """Alerts for tracking specific bills or legislative topics"""
    
    ALERT_TYPE_CHOICES = [
        ('bill', 'Specific Bill'),
        ('keyword', 'Keyword/Topic'),
        ('sponsor', 'Bill Sponsor'),
        ('subject', 'Policy Subject'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='legislative_alerts')
    alert_type = models.CharField(max_length=10, choices=ALERT_TYPE_CHOICES)
    name = models.CharField(max_length=200, help_text="Name for this alert")
    
    # Alert criteria
    bill = models.ForeignKey(LegislativeBill, on_delete=models.CASCADE, null=True, blank=True)
    keywords = models.TextField(blank=True, help_text="Comma-separated keywords")
    sponsor_bioguide_id = models.CharField(max_length=10, blank=True)
    subject_name = models.CharField(max_length=200, blank=True)
    
    # Settings
    is_active = models.BooleanField(default=True)
    email_notifications = models.BooleanField(default=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
        
    def __str__(self):
        return f"{self.name} ({self.get_alert_type_display()})"


class APILog(models.Model):
    """Log API calls to Congress.gov and other services"""
    
    SERVICE_CHOICES = [
        ('congress_gov', 'Congress.gov API'),
        ('propublica', 'ProPublica Congress API'),
        ('govtrack', 'GovTrack API'),
    ]
    
    service = models.CharField(max_length=20, choices=SERVICE_CHOICES)
    endpoint = models.CharField(max_length=500)
    method = models.CharField(max_length=10, default='GET')
    status_code = models.IntegerField()
    response_time = models.FloatField(help_text="Response time in seconds")
    
    # Request details
    request_params = models.JSONField(blank=True, null=True)
    user_agent = models.CharField(max_length=200, blank=True)
    
    # Response details
    response_size = models.IntegerField(null=True, blank=True)
    error_message = models.TextField(blank=True)
    
    timestamp = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-timestamp']
        
    def __str__(self):
        return f"{self.service} - {self.status_code} - {self.timestamp}"
