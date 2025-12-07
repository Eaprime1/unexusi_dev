import os
from git import Repo

# --- CONFIGURATION ---
# The main folder that holds all your projects
ROOT_DIR = "/home/sauron/unexusi/"

def get_git_status(repo_path):
    """Returns a status dictionary for a single repo."""
    try:
        repo = Repo(repo_path)
        status = {"path": repo_path, "name": os.path.basename(repo_path), "dirty": False, "ahead": 0, "behind": 0}
        
        # 1. Check Local Changes
        if repo.is_dirty(untracked_files=True):
            status["dirty"] = True

        # 2. Check Sync (Fetch hiddenly)
        try:
            origin = repo.remotes.origin
            origin.fetch()
            local_branch = repo.active_branch
            remote_branch = local_branch.tracking_branch()
            
            if remote_branch:
                status["behind"] = sum(1 for c in repo.iter_commits(f'{local_branch.name}..{remote_branch.name}'))
                status["ahead"] = sum(1 for c in repo.iter_commits(f'{remote_branch.name}..{local_branch.name}'))
        except:
            pass # Fails if no internet or no remote, that's okay

        return status
    except:
        return None

def main_dashboard():
    print(f"\n🌍 --- UNEXUSI FLEET COMMANDER ---")
    print(f"Scanning: {ROOT_DIR}...\n")

    repos_found = []

    # 1. SCANNING LOOP
    for folder_name in os.listdir(ROOT_DIR):
        folder_path = os.path.join(ROOT_DIR, folder_name)
        # Check if it's a folder and has a .git inside
        if os.path.isdir(folder_path) and os.path.isdir(os.path.join(folder_path, ".git")):
            
            # Get the status
            stat = get_git_status(folder_path)
            if stat:
                repos_found.append(stat)
                
                # Print Status Icon
                icon = "✅"
                msg = "Synced"
                if stat["dirty"]:
                    icon = "⚠️ "
                    msg = "Unsaved Work"
                elif stat["ahead"] > 0:
                    icon = "⬆️ "
                    msg = f"Ahead by {stat['ahead']}"
                elif stat["behind"] > 0:
                    icon = "⬇️ "
                    msg = f"Behind by {stat['behind']}"
                
                print(f"[{len(repos_found)}] {icon} {stat['name']:<20} | {msg}")

    # 2. INTERACTION LOOP
    if not repos_found:
        print("No repositories found.")
        return

    print("\n-------------------------------------------")
    choice = input("Enter the number to manage a repo (or 'q' to quit): ")
    
    if choice.isdigit():
        idx = int(choice) - 1
        if 0 <= idx < len(repos_found):
            target = repos_found[idx]
            print(f"\n🚀 Managing: {target['name']}")
            
            # Re-open repo to do work
            repo = Repo(target['path'])
            
            # Simple Logic: If dirty -> Save. If Ahead -> Push. If Behind -> Pull.
            if target['dirty']:
                if input("   >> Save changes? (y/n): ").lower() == 'y':
                    repo.git.add(all=True)
                    repo.index.commit(input("   >> Message: "))
                    print("   ✅ Saved.")
            
            # Check push/pull again after saving
            if input("   >> Sync with Cloud? (y/n): ").lower() == 'y':
                 print("   ... Syncing ...")
                 repo.remotes.origin.push()
                 repo.remotes.origin.pull()
                 print("   ✅ Done.")

if __name__ == "__main__":
    main_dashboard()
