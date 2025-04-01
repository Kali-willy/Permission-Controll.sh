#!/bin/bash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#          Android Permission Enabler for Non-Rooted Devices
#                     Created by: Willy Gailo
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#                         _______________
#                        /               \
#                       /                 \
#                      /                   \
#                     |   ╭━━━━━━━━━╮      |
#                     |   ┃         ┃      |
#                     |   ┃  ╭━╮╭━╮ ┃      |
#                     |   ┃  ╰━╯╰━╯ ┃      |
#                     |   ┃ ╭━━━━━━╮ ┃      |
#                     |   ┃ ╰━━━━━━╯ ┃      |
#                     |   ╰━━━━━━━━━╯      |
#                      \                   /
#                       \                 /
#                        \_______________/
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Display banner
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "          Android Permission Enabler for Non-Rooted Devices"
echo "                     Created by: Willy Gailo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Function to check if ADB is installed
check_adb() {
    if ! command -v adb &> /dev/null; then
        echo "[ERROR] ADB is not installed or not in PATH"
        echo "Please install Android Debug Bridge (ADB) first"
        exit 1
    else
        echo "[✓] ADB is installed"
    fi
}

# Function to check device connection
check_device() {
    local devices=$(adb devices | grep -v "List" | grep "device" | wc -l)
    if [ "$devices" -eq 0 ]; then
        echo "[ERROR] No device connected"
        echo "Please connect your Android device and enable USB debugging"
        exit 1
    else
        echo "[✓] Device connected"
        echo ""
    fi
}

# Function to grant permissions
grant_permission() {
    local app_package=$1
    local permission=$2
    
    echo "Granting $permission to $app_package..."
    adb shell pm grant $app_package $permission
    
    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "[✓] Permission granted successfully"
    else
        echo "[!] Failed to grant permission"
    fi
}

# Function to apply system settings
apply_system_setting() {
    local setting_type=$1
    local setting_name=$2
    local setting_value=$3
    
    echo "Setting $setting_type $setting_name to $setting_value..."
    adb shell "settings put $setting_type $setting_name $setting_value"
    
    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "[✓] Setting applied successfully"
    else
        echo "[!] Failed to apply setting"
    fi
}

# Function to enable app
enable_app() {
    local app_package=$1
    
    echo "Enabling $app_package..."
    adb shell pm enable $app_package
    
    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "[✓] App enabled successfully"
    else
        echo "[!] Failed to enable app"
    fi
}

# Function to apply property using adb or root
apply_property() {
    local prop_name=$1
    local prop_value=$2
    
    echo "Applying property $prop_name to $prop_value..."
    
    # Try with ADB first
    adb shell "setprop $prop_name $prop_value"
    
    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "[✓] Property applied successfully with ADB"
    else
        echo "[!] ADB method failed, trying alternative methods..."
        
        # Try with Termux method
        echo "Trying with Termux method..."
        adb shell "su -c 'setprop $prop_name $prop_value'"
        
        if [ $? -eq 0 ]; then
            echo "[✓] Property applied successfully with Termux"
        else
            echo "[!] Failed to apply property with available methods"
        fi
    fi
}

# Main function
main() {
    # Check prerequisites
    check_adb
    check_device
    
    echo "Starting permission setup..."
    echo ""
    
    # Enable and grant permissions for Termux
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Setting up Termux"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    enable_app "com.termux"
    grant_permission "com.termux" "android.permission.READ_EXTERNAL_STORAGE"
    grant_permission "com.termux" "android.permission.WRITE_EXTERNAL_STORAGE"
    grant_permission "com.termux" "android.permission.FOREGROUND_SERVICE"
    grant_permission "com.termux" "android.permission.WAKE_LOCK"
    
    # Additional permissions for Termux
    grant_permission "com.termux" "android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"
    grant_permission "com.termux" "android.permission.REQUEST_INSTALL_PACKAGES"
    
    # Disable phantom process monitoring for better Termux performance
    echo "Disabling phantom process monitoring for Termux..."
    apply_system_setting "global" "settings_enable_monitor_phantom_procs" "false"
    
    # Alternative methods for phantom process monitoring
    echo "Applying alternative methods for phantom process monitoring..."
    apply_property "persist.sys.fflag.override.settings_enable_monitor_phantom_procs" "false"
    
    # Additional settings for non-rooted devices
    echo "Applying additional optimizations for non-rooted device..."
    apply_system_setting "global" "hidden_api_policy_pre_p_apps" "1"
    apply_system_setting "global" "hidden_api_policy_p_apps" "1"
    apply_system_setting "global" "hidden_api_policy" "1"
    echo ""
    
    # Enable and grant permissions for Brevent
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Setting up Brevent"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    enable_app "me.piebridge.brevent"
    grant_permission "me.piebridge.brevent" "android.permission.PACKAGE_USAGE_STATS"
    grant_permission "me.piebridge.brevent" "android.permission.GET_APP_OPS_STATS"
    grant_permission "me.piebridge.brevent" "android.permission.DUMP"
    
    # Additional permissions for Brevent
    grant_permission "me.piebridge.brevent" "android.permission.WRITE_SECURE_SETTINGS"
    grant_permission "me.piebridge.brevent" "android.permission.REAL_GET_TASKS"
    grant_permission "me.piebridge.brevent" "android.permission.INTERACT_ACROSS_USERS"
    echo ""
    
    # Enable and grant permissions for Qute
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Setting up Qute Browser"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    enable_app "com.qutebrowser.qute"
    grant_permission "com.qutebrowser.qute" "android.permission.INTERNET"
    grant_permission "com.qutebrowser.qute" "android.permission.ACCESS_NETWORK_STATE"
    grant_permission "com.qutebrowser.qute" "android.permission.WRITE_EXTERNAL_STORAGE"
    grant_permission "com.qutebrowser.qute" "android.permission.READ_EXTERNAL_STORAGE"
    
    # Additional permissions for Qute Browser
    grant_permission "com.qutebrowser.qute" "android.permission.CAMERA"
    grant_permission "com.qutebrowser.qute" "android.permission.RECORD_AUDIO"
    grant_permission "com.qutebrowser.qute" "android.permission.MODIFY_AUDIO_SETTINGS"
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "                      Setup Completed!"
    echo "                 Created by: Willy Gailo"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo ""
    echo "All permissions have been granted and system optimizations applied."
    echo "You can now use these apps on your non-rooted device with enhanced functionality."
    echo ""
    echo "Additional commands for manual execution if needed:"
    echo "Termux: su -c \"settings put global settings_enable_monitor_phantom_procs false\""
    echo "ADB: adb shell \"settings put global settings_enable_monitor_phantom_procs false\""
    echo "Root: su -c \"setprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs false\""
    echo ""
    echo "Thank you for using this script!"
}

# Execute main function
main