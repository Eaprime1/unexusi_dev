#!/bin/bash
# ∰◊€π¿🌌∞ SDWG Google Drive Mount Module
# Termux GDrive Mount v1.0 - 202507300855
# Function: Simple Google Drive mounting for Termux

# Avatar Identity
AVATAR_NAME="DriveMancer"
AVATAR_VERSION="1.0"
SCRIPT_DATE="202507300855"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
WORK_DIR=$(pwd)
LOG_DIR="$WORK_DIR/FileMancer_Logs"
MOUNT_DIR="$WORK_DIR/gdrive_mount"
LOG_FILE="$LOG_DIR/gdrive_mount_$(date +%Y%m%d_%H%M%S).log"

# Create directories
mkdir -p "$LOG_DIR"
mkdir -p "$MOUNT_DIR"

# Logging function
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Colored output
print_colored() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check dependencies
check_dependencies() {
    print_colored $BLUE "🔍 Checking dependencies..."
    
    local missing_deps=()
    
    # Check for rclone
    if ! command -v rclone &> /dev/null; then
        missing_deps+=("rclone")
    fi
    
    # Check for fuse (if available)
    if ! pkg list-installed | grep -q "fuse2"; then
        print_colored $YELLOW "⚠️  Note: fuse2 not installed (may be needed for mounting)"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_colored $RED "❌ Missing dependencies: ${missing_deps[*]}"
        print_colored $YELLOW "💡 Install with: pkg install ${missing_deps[*]}"
        return 1
    fi
    
    print_colored $GREEN "✅ Dependencies OK"
    return 0
}

# Setup rclone config
setup_rclone() {
    print_colored $BLUE "🔧 Setting up rclone configuration..."
    
    if [ ! -f "$HOME/.config/rclone/rclone.conf" ]; then
        print_colored $YELLOW "📝 No rclone config found. Running setup..."
        rclone config
    else
        print_colored $GREEN "✅ Rclone config exists"
        
        # List configured remotes
        local remotes=$(rclone listremotes)
        if [ -n "$remotes" ]; then
            print_colored $CYAN "📋 Available remotes:"
            echo "$remotes"
        else
            print_colored $YELLOW "⚠️  No remotes configured. Running setup..."
            rclone config
        fi
    fi
}

# Mount Google Drive
mount_drive() {
    local remote_name="$1"
    local folder_path="$2"
    
    print_colored $BLUE "🔗 Mounting Google Drive..."
    log_message "INFO" "Attempting to mount $remote_name:$folder_path to $MOUNT_DIR"
    
    # Check if already mounted
    if mountpoint -q "$MOUNT_DIR"; then
        print_colored $YELLOW "⚠️  Drive already mounted. Unmounting first..."
        fusermount -u "$MOUNT_DIR" 2>/dev/null || true
        sleep 2
    fi
    
    # Attempt to mount
    local mount_cmd="rclone mount $remote_name:$folder_path $MOUNT_DIR --daemon --vfs-cache-mode writes"
    
    print_colored $CYAN "🚀 Executing: $mount_cmd"
    
    if eval "$mount_cmd"; then
        sleep 3  # Give time for mount to establish
        
        if mountpoint -q "$MOUNT_DIR"; then
            print_colored $GREEN "✅ Google Drive mounted successfully!"
            print_colored $CYAN "📁 Mount point: $MOUNT_DIR"
            log_message "SUCCESS" "Google Drive mounted to $MOUNT_DIR"
            
            # List contents to verify
            print_colored $BLUE "📂 Contents preview:"
            ls -la "$MOUNT_DIR" | head -10
            
            return 0
        else
            print_colored $RED "❌ Mount failed - directory not accessible"
            log_message "ERROR" "Mount command succeeded but directory not accessible"
            return 1
        fi
    else
        print_colored $RED "❌ Mount command failed"
        log_message "ERROR" "rclone mount command failed"
        return 1
    fi
}

# Unmount Google Drive
unmount_drive() {
    print_colored $BLUE "🔓 Unmounting Google Drive..."
    
    if mountpoint -q "$MOUNT_DIR"; then
        if fusermount -u "$MOUNT_DIR"; then
            print_colored $GREEN "✅ Google Drive unmounted successfully"
            log_message "SUCCESS" "Google Drive unmounted from $MOUNT_DIR"
        else
            print_colored $RED "❌ Failed to unmount"
            log_message "ERROR" "Failed to unmount Google Drive"
            return 1
        fi
    else
        print_colored $YELLOW "⚠️  No drive currently mounted"
        log_message "INFO" "No drive mounted at $MOUNT_DIR"
    fi
}

# Check mount status
check_mount_status() {
    print_colored $BLUE "📊 Checking mount status..."
    
    if mountpoint -q "$MOUNT_DIR"; then
        print_colored $GREEN "✅ Google Drive is mounted"
        print_colored $CYAN "📁 Mount point: $MOUNT_DIR"
        
        # Show some stats
        local file_count=$(find "$MOUNT_DIR" -maxdepth 1 -type f | wc -l)
        local dir_count=$(find "$MOUNT_DIR" -maxdepth 1 -type d | wc -l)
        
        print_colored $YELLOW "📊 Files: $file_count, Directories: $((dir_count - 1))"
    else
        print_colored $RED "❌ No Google Drive mounted"
    fi
}

# Main function
main() {
    print_colored $PURPLE "🌟 DriveMancer Avatar Initializing..."
    print_colored $PURPLE "∰◊€π¿🌌∞ SDWG Google Drive Mount System"
    echo
    
    log_message "START" "DriveMancer mount operation initiated"
    
    # Check dependencies
    if ! check_dependencies; then
        return 1
    fi
    
    # Setup rclone if needed
    setup_rclone
    
    # Get user input for operation
    echo -e "${CYAN}🎯 Select operation:${NC}"
    echo "1) Mount Google Drive"
    echo "2) Unmount Google Drive"
    echo "3) Check mount status"
    echo "4) Configure rclone"
    echo -e "${CYAN}Enter choice (1-4):${NC}"
    read -r choice
    
    case $choice in
        1)
            # Mount operation
            echo -e "${CYAN}📝 Enter remote name (from rclone config):${NC}"
            read -r remote_name
            
            if [ -z "$remote_name" ]; then
                print_colored $RED "❌ Remote name required"
                return 1
            fi
            
            echo -e "${CYAN}📁 Enter folder path (leave empty for root):${NC}"
            read -r folder_path
            
            mount_drive "$remote_name" "$folder_path"
            ;;
        2)
            # Unmount operation
            unmount_drive
            ;;
        3)
            # Status check
            check_mount_status
            ;;
        4)
            # Reconfigure rclone
            rclone config
            ;;
        *)
            print_colored $RED "❌ Invalid choice"
            return 1
            ;;
    esac
    
    log_message "END" "DriveMancer operation completed"
}

# Execute if run directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi

# Future Enhancement Notes:
# ========================
# 1. Multiple Mount Points
#    - Support mounting multiple drives simultaneously
#    - Named mount points for different projects
#    - Quick switching between mounts
#
# 2. Advanced Options
#    - Custom rclone flags for performance tuning
#    - Bandwidth limiting options
#    - Encryption support
#
# 3. Integration Features
#    - Auto-mount on script startup
#    - Integration with FileMancer for seamless operations
#    - Sync status monitoring
#
# 4. Backup and Sync
#    - Two-way sync capabilities
#    - Scheduled sync operations
#    - Conflict resolution strategies
#
# 5. GUI Integration
#    - Terminal UI for easier operation
#    - Mount point browser
#    - Real-time status dashboard