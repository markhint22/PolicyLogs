"""
Django management command to sync federal legislative bills
"""

from django.core.management.base import BaseCommand, CommandError
from bills.services import BillSyncService


class Command(BaseCommand):
    help = 'Sync federal legislative bills from Congress.gov API'

    def add_arguments(self, parser):
        parser.add_argument(
            '--congress',
            type=int,
            default=118,
            help='Congress number (default: 118 for current congress)',
        )
        parser.add_argument(
            '--days-back',
            type=int,
            default=7,
            help='Number of days back to sync (default: 7)',
        )
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be synced without making changes',
        )

    def handle(self, *args, **options):
        congress = options['congress']
        days_back = options['days_back']
        dry_run = options['dry_run']

        self.stdout.write(
            self.style.SUCCESS(
                f'Starting bill sync for Congress {congress} '
                f'(last {days_back} days){"[DRY RUN]" if dry_run else ""}'
            )
        )

        try:
            service = BillSyncService()
            
            if dry_run:
                # Test API connection for dry run
                try:
                    recent_bills = service.api.get_recent_bills(congress=congress, limit=5)
                    if recent_bills.get('bills'):
                        sample_title = recent_bills["bills"][0].get("title", "No title")
                        self.stdout.write(
                            f'DRY RUN: Would sync bills from Congress.gov API\n'
                            f'  - API connection successful\n'  
                            f'  - Found {len(recent_bills["bills"])} recent bills to process\n'
                            f'  - Sample: {sample_title[:60]}...'
                        )
                    else:
                        self.stdout.write('DRY RUN: No bills found or API error')
                except Exception as e:
                    self.stdout.write(f'DRY RUN: API test failed - {e}')
                return
            
            # Perform the sync
            stats = service.sync_recent_bills(congress=congress, days_back=days_back)
            
            # Report results
            self.stdout.write(
                self.style.SUCCESS(
                    f'Sync completed successfully:\n'
                    f'  - Bills created: {stats["bills_created"]}\n'
                    f'  - Bills updated: {stats["bills_updated"]}\n'
                    f'  - Subjects created: {stats["subjects_created"]}\n'
                    f'  - Actions created: {stats["actions_created"]}\n'
                    f'  - Cosponsors created: {stats["cosponsors_created"]}'
                )
            )
            
            if stats['errors']:
                self.stdout.write(
                    self.style.ERROR(f'Errors encountered ({len(stats["errors"])}):')
                )
                for error in stats['errors']:
                    self.stdout.write(self.style.ERROR(f'  - {error}'))
        
        except Exception as e:
            raise CommandError(f'Sync failed: {e}') from e
