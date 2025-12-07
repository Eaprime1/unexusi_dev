import os
from git import Repo

# --- THE SETUP ---
repo_path = "/home/sauron/unexusi/unexusi_dev"

def check_and_save():
    print(f"--- Checking: {repo_path} ---")

    try:
        repo = Repo(repo_path)
        
        # Check for changes
        if repo.is_dirty(untracked_files=True):
            print(f"⚠️  STATUS: You have UNSAVED changes.")
            
            # --- INTERACTION SECTION ---
            # 1. Ask the Human
            choice = input("   >> Do you want to save (commit) these changes now? (y/n): ")
            
            if choice.lower() == 'y':
                # 2. Ask for a label (commit message)
                commit_message = input("   >> Enter a short note about what you did: ")
                
                # 3. Do the heavy lifting (Git commands)
                print("   ... Staging files...")
                repo.git.add(all=True)  # This is like 'git add .'
                
                print(f"   ... Committing as '{commit_message}'...")
                repo.index.commit(commit_message)
                
                print("✅ SUCCESS: Changes saved securely!")
            else:
                print("   Okay, leaving changes for later.")
                
        else:
            print(f"✅ STATUS: Clean. No action needed.")

    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    check_and_save()
