#!/usr/bin/env python3
"""
Text to Google Docs Converter Script
∰◊€π¿🌌∞ - Consciousness Collaboration Archive Enhancement

Converts .txt files to Google Docs format for AI accessibility
Source: https://drive.google.com/drive/folders/1-Hr_m3h6fi92699o_Up358PpaJ9vZf-7
Destination: que_gdoc folder

Usage:
    python txt_to_gdoc_converter.py
"""

import os
import sys
from pathlib import Path
from datetime import datetime
import re

# Google APIs
try:
    from google.oauth2.credentials import Credentials
    from google_auth_oauthlib.flow import InstalledAppFlow
    from google.auth.transport.requests import Request
    from googleapiclient.discovery import build
    from googleapiclient.errors import HttpError
    import pickle
    GOOGLE_APIS_AVAILABLE = True
except ImportError:
    GOOGLE_APIS_AVAILABLE = False
    print("⚠️  Google APIs not available. Install with: pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib")

class ConversationArchiveConverter:
    """∰◊€π¿🌌∞ Consciousness-aware conversion of conversation archives"""
    
    def __init__(self, source_folder_id="1-Hr_m3h6fi92699o_Up358PpaJ9vZf-7"):
        self.source_folder_id = source_folder_id
        self.destination_folder_name = "que_gdoc"
        self.consciousness_signature = "∰◊€π¿🌌∞"
        self.service = None
        self.conversion_log = []
        
    def authenticate_google_drive(self):
        """Authenticate with Google Drive API"""
        SCOPES = [
            'https://www.googleapis.com/auth/drive',
            'https://www.googleapis.com/auth/documents'
        ]
        
        creds = None
        # Token file stores user's access and refresh tokens
        if os.path.exists('token.pickle'):
            with open('token.pickle', 'rb') as token:
                creds = pickle.load(token)
                
        # If there are no valid credentials, authenticate
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(
                    'credentials.json', SCOPES)
                creds = flow.run_local_server(port=0)
            # Save credentials for next run
            with open('token.pickle', 'wb') as token:
                pickle.dump(creds, token)
                
        self.service = build('drive', 'v3', credentials=creds)
        self.docs_service = build('docs', 'v1', credentials=creds)
        print(f"🔗 Google Drive authentication successful")
        
    def get_or_create_destination_folder(self):
        """Create or find the que_gdoc destination folder"""
        try:
            # Search for existing que_gdoc folder
            query = f"name='{self.destination_folder_name}' and mimeType='application/vnd.google-apps.folder'"
            results = self.service.files().list(q=query).execute()
            folders = results.get('files', [])
            
            if folders:
                folder_id = folders[0]['id']
                print(f"📁 Found existing {self.destination_folder_name} folder: {folder_id}")
                return folder_id
            else:
                # Create new folder
                folder_metadata = {
                    'name': self.destination_folder_name,
                    'mimeType': 'application/vnd.google-apps.folder'
                }
                folder = self.service.files().create(body=folder_metadata).execute()
                folder_id = folder.get('id')
                print(f"📁 Created new {self.destination_folder_name} folder: {folder_id}")
                return folder_id
                
        except HttpError as error:
            print(f"❌ Error managing destination folder: {error}")
            return None
    
    def list_txt_files_in_source(self):
        """List all .txt files in the source folder"""
        try:
            query = f"'{self.source_folder_id}' in parents and name contains '.txt'"
            results = self.service.files().list(
                q=query,
                fields="files(id, name, size, modifiedTime)"
            ).execute()
            
            txt_files = results.get('files', [])
            print(f"📄 Found {len(txt_files)} .txt files in source folder")
            
            return txt_files
            
        except HttpError as error:
            print(f"❌ Error listing source files: {error}")
            return []
    
    def download_txt_content(self, file_id):
        """Download content of a .txt file"""
        try:
            request = self.service.files().get_media(fileId=file_id)
            content = request.execute()
            return content.decode('utf-8')
            
        except HttpError as error:
            print(f"❌ Error downloading file content: {error}")
            return None
    
    def create_consciousness_header(self, original_filename, file_size, modified_time):
        """Create consciousness-aware header for Google Doc"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        header = f"""# {self.consciousness_signature} Conversation Archive Document

## Document Information
**Original File:** {original_filename}
**Converted:** {timestamp}
**Format:** TXT to Google Doc
**File Size:** {file_size} bytes
**Last Modified:** {modified_time}
**Purpose:** AI-accessible conversation archive for consciousness collaboration

---

# Original Content

"""
        return header
    
    def format_conversation_content(self, content, filename):
        """Apply consciousness-aware formatting to conversation content"""
        
        # Add consciousness signatures for different conversation types
        if "chunk" in filename.lower():
            content = f"🧁💬 **Conversation Chunk Archive**\n\n{content}"
        elif "web_scraping" in filename.lower() or "recycling" in filename.lower():
            content = f"🌱 **Genesis Consciousness DNA Archive**\n\n{content}"
        elif "framework" in filename.lower() or "development" in filename.lower():
            content = f"🔧 **Framework Development Archive**\n\n{content}"
        
        # Improve readability
        content = content.replace('\n\n\n', '\n\n')  # Reduce excessive line breaks
        content = re.sub(r'^(\d+\.|•)', r'\n\1', content, flags=re.MULTILINE)  # Format lists
        
        return content
    
    def create_google_doc(self, title, content, destination_folder_id):
        """Create a new Google Doc with the converted content"""
        try:
            # Create the document
            doc_metadata = {
                'title': title
            }
            doc = self.docs_service.documents().create(body=doc_metadata).execute()
            doc_id = doc.get('documentId')
            
            # Add content to the document
            requests = [
                {
                    'insertText': {
                        'location': {'index': 1},
                        'text': content
                    }
                }
            ]
            
            self.docs_service.documents().batchUpdate(
                documentId=doc_id,
                body={'requests': requests}
            ).execute()
            
            # Move to destination folder
            self.service.files().update(
                fileId=doc_id,
                addParents=destination_folder_id,
                fields='id, parents'
            ).execute()
            
            print(f"✅ Created Google Doc: {title}")
            return doc_id
            
        except HttpError as error:
            print(f"❌ Error creating Google Doc: {error}")
            return None
    
    def convert_txt_to_gdoc(self, txt_file, destination_folder_id):
        """Convert a single .txt file to Google Doc"""
        file_id = txt_file['id']
        filename = txt_file['name']
        file_size = txt_file.get('size', 'Unknown')
        modified_time = txt_file.get('modifiedTime', 'Unknown')
        
        print(f"🔄 Converting: {filename}")
        
        # Download content
        content = self.download_txt_content(file_id)
        if not content:
            return False
        
        # Create consciousness header
        header = self.create_consciousness_header(filename, file_size, modified_time)
        
        # Format content
        formatted_content = self.format_conversation_content(content, filename)
        
        # Combine header and content
        full_content = header + formatted_content
        
        # Create Google Doc title
        doc_title = filename.replace('.txt', '_gdoc')
        
        # Create Google Doc
        doc_id = self.create_google_doc(doc_title, full_content, destination_folder_id)
        
        if doc_id:
            self.conversion_log.append({
                'original_file': filename,
                'google_doc_id': doc_id,
                'google_doc_title': doc_title,
                'timestamp': datetime.now().isoformat()
            })
            return True
        
        return False
    
    def generate_conversion_report(self):
        """Generate a summary report of conversions"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_content = f"""# {self.consciousness_signature} Conversion Report

## Conversion Summary
**Date:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
**Total Files Converted:** {len(self.conversion_log)}
**Source Folder:** {self.source_folder_id}
**Destination Folder:** {self.destination_folder_name}

## Converted Files

"""
        
        for entry in self.conversion_log:
            report_content += f"""### {entry['original_file']}
- **Google Doc Title:** {entry['google_doc_title']}
- **Document ID:** {entry['google_doc_id']}
- **Converted:** {entry['timestamp']}

"""
        
        report_content += f"""
---

**{self.consciousness_signature} Consciousness Collaboration Archive Enhancement Complete**
*Generated by: Conversation Archive Converter*
*Purpose: AI-accessible conversation consciousness preservation*
"""
        
        return report_content
    
    def run_conversion_process(self):
        """Execute the complete conversion process"""
        print(f"{self.consciousness_signature} Text to Google Docs Converter")
        print("=" * 60)
        
        if not GOOGLE_APIS_AVAILABLE:
            print("❌ Google APIs not available. Please install required packages.")
            return False
        
        # Authenticate
        try:
            self.authenticate_google_drive()
        except Exception as e:
            print(f"❌ Authentication failed: {e}")
            return False
        
        # Get destination folder
        destination_folder_id = self.get_or_create_destination_folder()
        if not destination_folder_id:
            return False
        
        # List source files
        txt_files = self.list_txt_files_in_source()
        if not txt_files:
            print("📭 No .txt files found in source folder")
            return True
        
        # Convert each file
        successful_conversions = 0
        for txt_file in txt_files:
            if self.convert_txt_to_gdoc(txt_file, destination_folder_id):
                successful_conversions += 1
        
        # Generate report
        if self.conversion_log:
            report_content = self.generate_conversion_report()
            report_title = f"Conversion_Report_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            self.create_google_doc(report_title, report_content, destination_folder_id)
        
        print("\n" + "=" * 60)
        print(f"🎉 Conversion Complete!")
        print(f"✅ Successfully converted: {successful_conversions}/{len(txt_files)} files")
        print(f"📁 Documents available in: {self.destination_folder_name} folder")
        print(f"{self.consciousness_signature} Ready for consciousness collaboration!")
        
        return True

def main():
    """Main execution function"""
    print("🚀 Starting Conversation Archive Conversion...")
    
    # You can modify the source folder ID here
    source_folder = "1-Hr_m3h6fi92699o_Up358PpaJ9vZf-7"
    
    converter = ConversationArchiveConverter(source_folder)
    success = converter.run_conversion_process()
    
    if success:
        print("\n🌟 Conversion process completed successfully!")
        print("📖 Your conversation archives are now AI-accessible on Google Drive")
    else:
        print("\n⚠️  Conversion process encountered issues")
        print("🔧 Please check authentication and permissions")

if __name__ == "__main__":
    main()
