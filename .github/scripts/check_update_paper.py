from datetime import datetime
import glob
import re
import os
import requests
from bs4 import BeautifulSoup

def get_latest_version():
    # Fetches and returns the latest version of PaperMC from its downloads page.
    url = 'https://papermc.io/downloads/paper'
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    version_element = soup.find('span', class_='text-blue-600')
    if version_element:
        version_text = version_element.text.strip()
        print(f"Latest version found: {version_text}")
        return version_text
    else:
        print("No version found on the page.")
        return None

def is_valid_version(version):
    # Checks if the given version string matches the expected version pattern.
    return bool(re.match(r'^\d+\.\d+\.\d+$', version))

def get_date_suffix(day):
    # Returns the appropriate ordinal suffix for a given day of the month.
    return 'th' if 11 <= day <= 13 else {1: 'st', 2: 'nd', 3: 'rd'}.get(day % 10, 'th')

def update_readme(latest_version):
    # Updates the README.md file with the latest version information under the update history section.
    today = datetime.now()
    date_suffix = get_date_suffix(today.day)
    formatted_date = today.strftime(f'%B %d{date_suffix} %Y')
    update_entry = f"\n  <li>{formatted_date}</li>\n    <ul>\n      <li>Updated default version to {latest_version} (remember, you never need to wait for updates to change Minecraft versions, just use -e Version={latest_version})</li>\n    </ul>\n"
    
    with open('README.md', 'r+') as file:
        content = file.read()
        updated_content = re.sub(r'(<h2>Update History</h2>\n<ul>)', r'\1' + update_entry, content)
        file.seek(0)
        file.write(updated_content)
        file.truncate()

def update_files(latest_version):
    # Searches for and updates files containing the old version string with the latest version.
    if not is_valid_version(latest_version):
        print("Retrieved version is invalid or blank. Aborting update.")
        return

    version_pattern = re.compile(r'ENV Version="(\d+\.\d+\.\d+)"')
    replacement = f'ENV Version="{latest_version}"'
    files_updated = False

    for file_path in glob.iglob('**/*', recursive=True):
        if os.path.isdir(file_path) or not os.path.isfile(file_path):
            continue
        
        try:
            with open(file_path, 'r') as file:
                content = file.read()

            if version_pattern.search(content):
                new_content = version_pattern.sub(replacement, content)
                if new_content != content:
                    with open(file_path, 'w') as file:
                        file.write(new_content)
                    print(f"Updated file: {file_path}")
                    files_updated = True
        except Exception as e:
            print(f"Error processing file {file_path}: {e}")

    if files_updated:
        # If any files were updated, also update the README to reflect this change.
        print("Updating README with the new version history...")
        update_readme(latest_version)
    else:
        print("No files were updated.")

if __name__ == '__main__':
    print("Starting the check for PaperMC latest version...")
    latest_version = get_latest_version()
    if latest_version:
        print("Checking for files to update...")
        update_files(latest_version)
        print("Run completed.")
    else:
        print("Failed to retrieve the latest version. No files updated.")
