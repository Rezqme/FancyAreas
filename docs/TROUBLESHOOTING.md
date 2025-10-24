# FancyAreas Troubleshooting Guide

Common issues and their solutions.

## Table of Contents

1. [Permission Issues](#permission-issues)
2. [Overlay Issues](#overlay-issues)
3. [Snapping Issues](#snapping-issues)
4. [Layout Issues](#layout-issues)
5. [Performance Issues](#performance-issues)
6. [Multi-Monitor Issues](#multi-monitor-issues)
7. [iCloud Sync Issues](#icloud-sync-issues)
8. [App Restoration Issues](#app-restoration-issues)
9. [Startup Issues](#startup-issues)
10. [Error Messages](#error-messages)

## Permission Issues

### Zone Overlay Doesn't Appear

**Symptom**: No overlay shows when dragging windows with modifier key.

**Cause**: Missing Screen Recording permission.

**Solution**:
1. Open **System Preferences → Security & Privacy → Privacy**
2. Click **Screen Recording** in the sidebar
3. Click the lock icon to make changes
4. Check the box next to **FancyAreas**
5. **Quit and relaunch FancyAreas** (required for permission to take effect)

**Note**: macOS requires this permission to monitor global mouse events. FancyAreas does not actually record your screen.

---

### Windows Don't Snap

**Symptom**: Windows don't resize/move when dropped in zones.

**Cause**: Missing Accessibility permission.

**Solution**:
1. Open **System Preferences → Security & Privacy → Privacy**
2. Click **Accessibility** in the sidebar
3. Click the lock icon to make changes
4. Check the box next to **FancyAreas**
5. Try snapping a window again (no restart needed)

**If still not working**:
- Try a different app (some apps restrict window control)
- Exit full-screen mode (green button or Ctrl+Cmd+F)
- Exit Split View if active

---

### Permission Reset After macOS Update

**Symptom**: FancyAreas stops working after updating macOS.

**Cause**: macOS updates sometimes reset app permissions.

**Solution**:
1. Check both Accessibility and Screen Recording permissions
2. If unchecked, re-enable them
3. Quit and relaunch FancyAreas

**Prevention**: After major macOS updates, always check app permissions.

---

### Can't Enable Permission (Grayed Out)

**Symptom**: Cannot check the box for FancyAreas in System Preferences.

**Cause**: FancyAreas hasn't requested the permission yet.

**Solution**:
1. Launch FancyAreas first
2. Try to use the feature that requires permission
3. macOS will add FancyAreas to the permission list
4. Go back to System Preferences and enable it

---

## Overlay Issues

### Overlay Shows on Wrong Display

**Symptom**: Overlay appears on incorrect monitor.

**Cause**: Display arrangement changed, or zone assigned to wrong display.

**Solution**:
1. Open Layout Management window
2. Edit the problematic layout
3. For each zone, verify **Display** property is correct
4. Save changes
5. Reactivate layout

---

### Overlay Appears But Zones Are Misaligned

**Symptom**: Overlay zones don't match expected positions.

**Cause**: Display resolution changed, or layout created on different monitor.

**Solution**:

**If resolution changed**:
1. Edit the layout
2. Adjust zone positions for new resolution
3. Save changes

**If using layout on different monitor**:
1. Duplicate the layout
2. Adjust zone positions for current monitor
3. Rename appropriately (e.g., "Coding Setup - 4K")

---

### Overlay Is Too Transparent or Too Opaque

**Symptom**: Can't see zones clearly, or overlay blocks too much.

**Solution**:
1. Open **Preferences → Appearance**
2. Adjust **Overlay Opacity** slider
   - Increase for better visibility
   - Decrease if too intrusive
3. Changes apply immediately

**Recommended values**:
- Light backgrounds: 20-30%
- Dark backgrounds: 30-40%
- High contrast needs: 50-60%

---

### Zone Numbers Not Showing

**Symptom**: Zone numbers don't appear on overlay.

**Solution**:
1. Open **Preferences → Appearance**
2. Enable **Show Zone Numbers**
3. If still not visible, check that zones have zone numbers assigned (1-9)

---

### Overlay Animations Stuttering

**Symptom**: Overlay fade in/out is choppy or laggy.

**Solution**:

**On older Macs**:
1. Open **Preferences → General**
2. Disable **Enable Animations**
3. Overlay will appear/disappear instantly

**If other apps are resource-intensive**:
- Close background applications
- Reduce number of zones (fewer zones = better performance)
- Lower overlay opacity slightly

---

### Overlay Doesn't Hide After Releasing Modifier Key

**Symptom**: Overlay stays visible after letting go of modifier key.

**Cause**: Event monitoring interrupted or key event not detected.

**Solution**:
1. Press and release modifier key again
2. Press Escape to force hide overlay
3. If persists, restart FancyAreas

**Prevention**: Ensure Screen Recording permission is enabled.

---

## Snapping Issues

### Window Snaps to Wrong Size

**Symptom**: Window doesn't fill entire zone.

**Cause**: App has minimum/maximum size constraints.

**Solution**:

**If window is too small**:
- App's minimum size is larger than zone
- Make zone larger or use different app

**If window is too large**:
- App's maximum size is smaller than zone
- This is rare, usually not an issue

**If maintaining aspect ratio**:
- Some apps (like Preview) maintain image aspect ratio
- Window will fill zone as much as possible while maintaining ratio
- This is expected behavior

---

### Window Snaps to Wrong Position

**Symptom**: Window positioned incorrectly within zone.

**Cause**: Zone spacing settings or multi-monitor coordinate issues.

**Solution**:

**Check spacing**:
1. Open **Preferences → General**
2. Check **Edge Spacing** and **Zone Spacing** values
3. Set to 0 for no gaps, or adjust as needed

**Check zone bounds**:
1. Open Layout Management
2. Verify zone position values (X, Y, Width, Height)
3. Edit if needed

---

### Snapping Animation Is Laggy

**Symptom**: Window movement is choppy during snap.

**Solution**:

**Quick fix**:
1. Open **Preferences → General**
2. Disable **Enable Animations**
3. Snapping becomes instant

**Optimize performance**:
1. Reduce **Animation Duration** to 0.1s
2. Enable **Respect Reduce Motion**
3. Then enable Reduce Motion in:
   - System Preferences → Accessibility → Display → Reduce Motion

---

### Can't Snap Specific App

**Symptom**: One particular app never snaps.

**Cause**: App restricts window control.

**Known apps with restrictions**:
- Some security apps
- Certain games in windowed mode
- Protected system apps

**Solution**:
- Check app's preferences for "Allow window management"
- Try updating the app to latest version
- Contact app developer if issue persists

**Alternative**:
- Use app's built-in window management if available
- Position manually and don't use snapping for that app

---

### Full-Screen App Won't Snap

**Symptom**: Nothing happens when trying to snap a full-screen window.

**Cause**: macOS full-screen windows cannot be resized.

**Solution**:
1. Exit full-screen mode:
   - Click green button in title bar, OR
   - Press **Ctrl+Cmd+F**, OR
   - Move cursor to top of screen → click green button
2. Now window can be snapped normally

---

### Split View Windows Won't Snap

**Symptom**: Windows in macOS Split View don't respond to snapping.

**Cause**: Split View windows are in a special full-screen mode.

**Solution**:
1. Exit Split View:
   - Move cursor to top of screen
   - Hover over green button
   - Click **Exit Split View**
2. Windows return to normal windowing mode
3. Now they can be snapped

---

## Layout Issues

### Can't Create More Layouts

**Symptom**: "Layout limit reached" error when creating new layout.

**Cause**: FancyAreas enforces a 10-layout limit per machine.

**Solution**:

**Option 1: Delete unused layouts**
1. Open Layout Management
2. Select layouts you don't use
3. Press Delete key
4. Confirm deletion

**Option 2: Export old layouts**
1. Right-click layouts you want to keep but don't use regularly
2. Select "Export Layout..."
3. Save .fancyareas file to a backup location
4. Delete the layout from FancyAreas
5. Import later when needed

---

### Layout Won't Activate

**Symptom**: Clicking layout in menu does nothing.

**Cause**: Monitor configuration mismatch.

**Solution**:
1. Check for warning dialog when activating
2. If layout created on different monitor config:
   - Click "Continue Anyway" to activate with warning, OR
   - Create new layout for current monitor config

**If no warning appears**:
1. Check that you have permission (Accessibility)
2. Try restarting FancyAreas
3. Check error log at `~/Library/Logs/FancyAreas/app.log`

---

### Layout Disappeared from Menu

**Symptom**: Saved layout no longer appears in menu bar.

**Cause**: Layout file corrupted or deleted.

**Solution**:
1. Open Layout Management window
2. Check if layout appears in the list
3. If not in list, file was deleted
4. Restore from Time Machine backup if available
5. Or import from exported .fancyareas file if you have one

**Prevention**: Regularly export important layouts as backups.

---

### Can't Edit Layout

**Symptom**: Edit button grayed out or does nothing.

**Cause**: Layout file is read-only or corrupted.

**Solution**:
1. Locate layout file:
   - Open Finder
   - Go to `~/Library/Application Support/FancyAreas/Layouts/`
   - Find the .fancyareas file
2. Check file permissions:
   - Right-click file → Get Info
   - Ensure "Sharing & Permissions" shows Read & Write
3. If corrupted:
   - Delete the corrupted file
   - Re-create layout from scratch or import backup

---

### Zones Overlap After Editing

**Symptom**: Zone boundaries overlap, causing snap confusion.

**Cause**: Manual editing created overlapping zones.

**Solution**:
1. Open Layout Management
2. Edit the problematic layout
3. Adjust zone positions so they don't overlap
4. Use grid overlay to align zones precisely
5. Save changes

**Best practice**: Zones should touch edges but not overlap.

---

## Performance Issues

### High CPU Usage

**Symptom**: FancyAreas uses significant CPU (>10% when idle).

**Cause**: Event monitoring loop or spatial grid rebuild.

**Solution**:

**Check active layout**:
1. Deactivate current layout
2. Check if CPU usage drops
3. If yes, layout may have issues (e.g., too many zones)

**Disable animations**:
1. Preferences → General
2. Disable **Enable Animations**

**Restart FancyAreas**:
- Quit and relaunch
- Event monitoring may have gotten stuck

**If persists**:
- Check Console.app for errors
- Check log file: `~/Library/Logs/FancyAreas/app.log`
- Report issue on GitHub with log file

---

### High Memory Usage

**Symptom**: FancyAreas uses >200MB RAM.

**Expected usage**:
- Idle: 50-75MB
- Active with 1 layout: 75-100MB
- Active with 10 layouts: 100-150MB

**Cause**: Memory leak or too many layouts loaded.

**Solution**:
1. Quit FancyAreas
2. Delete unused layouts to reduce memory footprint
3. Relaunch FancyAreas
4. Monitor memory usage

**If still high**:
- Check for memory leaks in Activity Monitor
- Report issue on GitHub

---

### Slow Zone Detection

**Symptom**: Noticeable delay when hovering over zones.

**Cause**: Using Linear Search algorithm or too many zones.

**Solution**:
1. Open **Preferences → Advanced**
2. Ensure **Zone Detection Algorithm** is set to **Spatial Grid**
3. If still slow, reduce number of zones in layout

**Performance targets**:
- Spatial Grid: <1ms per detection (imperceptible)
- Linear Search: ~5ms per detection with 20 zones (noticeable)

---

### Startup Takes Too Long

**Symptom**: FancyAreas takes >5 seconds to launch.

**Expected startup**:
- Cold start: <1 second
- With auto-restore: <2 seconds

**Solution**:
1. Disable **Auto-restore last layout** in Preferences
2. Reduce number of saved layouts
3. Check for disk errors (Disk Utility → First Aid)

**If persists**:
- Check Console.app for startup errors
- Ensure SSD is healthy (HDD will be slower)

---

## Multi-Monitor Issues

### Zones on Wrong Monitor After Reconnecting

**Symptom**: Zones appear on different display after unplugging/replugging monitor.

**Cause**: Display IDs changed when reconnecting.

**Solution**:
1. Create separate layouts for each monitor configuration
2. Name them clearly:
   - "Laptop Only"
   - "Desk Setup (Laptop + External)"
   - "Home Setup (Dual Monitor)"
3. Manually switch layouts when changing monitor config

**Future enhancement**: Automatic layout switching based on monitor config is planned.

---

### Layout Incompatible with Current Monitors

**Symptom**: "Monitor configuration mismatch" warning when activating layout.

**Cause**: Layout created with different monitors (count, resolution, or arrangement).

**Solution**:

**Option 1: Create new layout**
- Create a new layout for your current monitor configuration
- Name it appropriately

**Option 2: Edit existing layout**
- Edit the layout
- Update zone positions for current monitors
- Save as new layout (duplicate first to preserve original)

**Option 3: Force activate**
- Click "Continue Anyway" in warning dialog
- Zones may be positioned incorrectly
- Edit layout to fix positioning

---

### Zones Span Multiple Monitors

**Symptom**: A zone appears to stretch across two displays.

**Cause**: Zone bounds incorrectly set to span displays.

**Solution**:
1. Open Layout Management
2. Edit the problematic layout
3. Select the spanning zone
4. Check zone bounds (X, Y, Width, Height)
5. Adjust to fit within single display
6. Save changes

**Note**: Zones cannot span multiple displays. Each zone must be fully contained within one display.

---

### External Monitor Not Detected

**Symptom**: FancyAreas doesn't see external monitor.

**Cause**: Monitor not detected by macOS, or display mirroring enabled.

**Solution**:

**Check System Preferences**:
1. Open **System Preferences → Displays**
2. Verify external monitor appears
3. Ensure **Mirror Displays** is OFF

**Refresh display detection**:
1. Unplug and replug monitor
2. Restart FancyAreas
3. Create new layout to verify display is detected

---

## iCloud Sync Issues

### Preferences Not Syncing

**Symptom**: Preference changes on one Mac don't appear on another.

**Cause**: iCloud sync disabled or iCloud having issues.

**Solution**:

**Enable iCloud sync**:
1. Open FancyAreas **Preferences → Advanced**
2. Enable **Sync Preferences**
3. Repeat on all Macs

**Verify iCloud**:
1. Open **System Preferences → Apple ID → iCloud**
2. Ensure **iCloud Drive** is enabled
3. Check iCloud status (green checkmark)

**Force sync**:
1. Toggle **Sync Preferences** off then on
2. Wait 1-2 minutes for sync to propagate
3. Check other Mac

**If still not syncing**:
- Sign out and back into iCloud on both Macs
- Check iCloud storage (may be full)
- Restart both Macs

---

### Layouts Not Syncing

**Symptom**: Layouts don't appear on other Mac.

**Cause**: Layout sync is not yet implemented.

**Solution**:
- Layouts are currently stored locally only
- Use Export/Import to transfer layouts between Macs:
  1. On Mac A: Right-click layout → Export
  2. Transfer .fancyareas file (AirDrop, email, cloud storage)
  3. On Mac B: Import layout

**Future**: iCloud layout sync is planned for a future release.

---

## App Restoration Issues

### Apps Don't Launch During Restoration

**Symptom**: "Failed to launch" notification when restoring apps.

**Cause**: App not found, or app path changed.

**Solution**:

**Verify app installed**:
1. Open Finder → Applications
2. Check if app exists
3. If missing, reinstall app

**Update app assignment**:
1. Open Layout Management
2. Edit the layout
3. Select the zone with failed app
4. Reassign the correct app
5. Save layout

**Check app bundle ID**:
- Some apps have bundle IDs that change between versions
- Reassigning app in Layout Management updates bundle ID

---

### Apps Launch But Don't Position Correctly

**Symptom**: App launches but window isn't moved to zone.

**Cause**: App launch timeout, or window title doesn't match.

**Solution**:

**Increase timeout**:
- FancyAreas waits 5 seconds for app to launch
- Some apps take longer (e.g., Xcode, Unity)
- Try restoring apps again after first launch

**Check window title filter**:
1. Open Layout Management
2. Edit layout
3. Check window title filter for that zone
4. Clear filter if not needed, or correct the filter

**Manual positioning**:
- If app continues to fail, position manually
- Or remove app assignment from that zone

---

### Restoration Takes Too Long

**Symptom**: "Restoring apps..." notification visible for >30 seconds.

**Cause**: Multiple apps launching simultaneously, some slow to start.

**Solution**:
- This is normal for layouts with many apps
- First launch of each app is slowest
- Subsequent restores will be faster

**Optimization**:
- Remove apps you don't actually need in the layout
- Use fewer "Zones + Apps" layouts
- Launch critical apps first, restore others later

---

### Restoration Stops Midway

**Symptom**: Some apps restore, others don't, with no error.

**Cause**: One app fails and stops the restoration process.

**Solution**:
1. Check notification for which app failed
2. Fix that app's issue (reinstall, update, etc.)
3. Try restoration again

**Workaround**:
- Temporarily remove problematic app from layout
- Restore remaining apps
- Launch problematic app manually

---

## Startup Issues

### FancyAreas Doesn't Launch on Login

**Symptom**: App doesn't start automatically despite "Launch on Login" enabled.

**Cause**: Login item not properly registered.

**Solution**:

**Re-enable Launch on Login**:
1. Open FancyAreas **Preferences → Advanced**
2. Disable **Launch on Login**
3. Wait 2 seconds
4. Enable **Launch on Login** again

**Check Login Items** (macOS 12 and earlier):
1. Open **System Preferences → Users & Groups**
2. Click **Login Items** tab
3. Verify **FancyAreas** is in the list
4. If not, add it manually:
   - Click **+** button
   - Navigate to Applications
   - Select FancyAreas
   - Click Add

**Check Login Items** (macOS 13+):
1. Open **System Settings → General → Login Items**
2. Verify **FancyAreas** appears under "Open at Login"
3. Ensure toggle is ON

---

### FancyAreas Crashes on Launch

**Symptom**: App opens and immediately crashes.

**Cause**: Corrupted preferences or layout files.

**Solution**:

**Reset preferences**:
1. Quit FancyAreas (if running)
2. Open Finder
3. Go to `~/Library/Preferences/`
4. Move `com.fancyareas.FancyAreas.plist` to Desktop (backup)
5. Launch FancyAreas again

**Reset layouts**:
1. Quit FancyAreas
2. Go to `~/Library/Application Support/FancyAreas/`
3. Move `Layouts` folder to Desktop (backup)
4. Launch FancyAreas again
5. Re-import layouts from backups

**Check crash log**:
1. Open Console.app
2. Search for "FancyAreas"
3. Look for crash reports
4. Share crash log when reporting issue on GitHub

---

### Menu Bar Icon Doesn't Appear

**Symptom**: FancyAreas running but no menu bar icon.

**Cause**: "Show icon in menu bar" disabled, or macOS menu bar hidden.

**Solution**:

**Enable menu bar icon**:
1. If FancyAreas is running, press **Cmd+Opt+Shift+L** to open Layout Management
2. Navigate to Preferences window
3. Go to **Appearance** tab
4. Enable **Show icon in menu bar**

**Check macOS menu bar**:
- In full-screen apps, menu bar auto-hides
- Move cursor to top of screen to reveal
- Exit full-screen mode to see menu bar normally

**Restart FancyAreas**:
1. Open Activity Monitor
2. Search for "FancyAreas"
3. Quit process
4. Launch FancyAreas from Applications folder

---

## Error Messages

### "Accessibility permission required"

**Meaning**: FancyAreas needs Accessibility permission to control windows.

**Solution**: See [Windows Don't Snap](#windows-dont-snap) above.

---

### "Screen Recording permission required"

**Meaning**: FancyAreas needs Screen Recording permission to monitor events.

**Solution**: See [Zone Overlay Doesn't Appear](#zone-overlay-doesnt-appear) above.

---

### "Layout limit reached"

**Meaning**: You have 10 layouts and can't create more.

**Solution**: See [Can't Create More Layouts](#cant-create-more-layouts) above.

---

### "Monitor configuration mismatch"

**Meaning**: Layout created for different monitor setup.

**Solution**: See [Layout Incompatible with Current Monitors](#layout-incompatible-with-current-monitors) above.

---

### "Failed to load layout"

**Meaning**: Layout file corrupted or missing.

**Solution**:
1. Try restarting FancyAreas
2. If layout still won't load, delete it and recreate
3. Restore from backup/export if available

---

### "Failed to save layout"

**Meaning**: Cannot write to disk.

**Possible causes**:
- Disk full
- Permission denied
- File system error

**Solution**:
1. Check available disk space (need at least 1GB free)
2. Check folder permissions:
   - `~/Library/Application Support/FancyAreas/` should be writable
3. Run Disk Utility → First Aid on your drive
4. Try saving with a different name

---

### "App not found: [BundleID]"

**Meaning**: Assigned app not installed or moved.

**Solution**: See [Apps Don't Launch During Restoration](#apps-dont-launch-during-restoration) above.

---

## Getting Additional Help

If your issue isn't covered here:

### 1. Check the Log File

```bash
# Open log file in Console
open ~/Library/Logs/FancyAreas/app.log
```

Look for ERROR or WARNING messages around the time of the issue.

### 2. Search GitHub Issues

Visit [FancyAreas Issues](https://github.com/your-org/FancyAreas/issues) and search for your problem.

### 3. Report a Bug

If you can't find a solution:

1. Go to [GitHub Issues](https://github.com/your-org/FancyAreas/issues)
2. Click **"New Issue"**
3. Include:
   - macOS version (e.g., "macOS 13.5")
   - FancyAreas version (menu bar → About)
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant log excerpts
   - Screenshots if helpful

### 4. Ask the Community

Visit [GitHub Discussions](https://github.com/your-org/FancyAreas/discussions) to ask questions and get help from other users.

---

**Last Updated**: 2025-01-24
