//
//  FirstRunSetupView.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import SwiftUI

/// First-run setup view that guides users through granting necessary permissions
struct FirstRunSetupView: View {
    @ObservedObject var permissionsManager = PermissionsManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var currentStep = 0

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Welcome to FancyAreas")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Let's set up the permissions you need")
                .font(.title3)
                .foregroundColor(.secondary)

            Spacer()

            // Permission steps
            if currentStep == 0 {
                permissionStepView(
                    icon: "hand.raised.fill",
                    permission: .accessibility,
                    isGranted: permissionsManager.hasAccessibilityPermission
                )
            } else if currentStep == 1 {
                permissionStepView(
                    icon: "rectangle.on.rectangle",
                    permission: .screenRecording,
                    isGranted: permissionsManager.hasScreenRecordingPermission
                )
            } else {
                completionView
            }

            Spacer()

            // Navigation buttons
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        currentStep -= 1
                    }
                }

                Spacer()

                if currentStep < 2 {
                    Button("Continue") {
                        if currentStep == 0 && !permissionsManager.hasAccessibilityPermission {
                            permissionsManager.requestAccessibilityPermission()
                        } else if currentStep == 1 && !permissionsManager.hasScreenRecordingPermission {
                            permissionsManager.requestScreenRecordingPermission()
                        }

                        // Move to next step after a delay to allow permission check
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        UserDefaults.standard.set(true, forKey: "hasCompletedFirstRun")
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(40)
        .frame(width: 600, height: 500)
        .onAppear {
            permissionsManager.checkAllPermissions()
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func permissionStepView(icon: String, permission: Permission, isGranted: Bool) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(isGranted ? .green : .blue)

            Text(permission.title)
                .font(.title)
                .fontWeight(.semibold)

            Text(permission.shortExplanation)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if isGranted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Permission granted")
                        .foregroundColor(.green)
                }
                .padding(.top, 8)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("This permission enables:")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    ForEach(permissionsManager.featuresRequiring(permission), id: \.self) { feature in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(feature)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Setup Complete!")
                .font(.title)
                .fontWeight(.bold)

            Text("FancyAreas is ready to help you manage your windows.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                Text("Next steps:")
                    .font(.headline)

                HStack(alignment: .top) {
                    Text("1.")
                    Text("Create your first zone layout from the menu bar")
                }

                HStack(alignment: .top) {
                    Text("2.")
                    Text("Hold modifier keys while dragging windows to snap them")
                }

                HStack(alignment: .top) {
                    Text("3.")
                    Text("Access preferences to customize your experience")
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)

            // Permission status summary
            VStack(spacing: 8) {
                permissionStatusRow(
                    permission: .accessibility,
                    isGranted: permissionsManager.hasAccessibilityPermission
                )
                permissionStatusRow(
                    permission: .screenRecording,
                    isGranted: permissionsManager.hasScreenRecordingPermission
                )
            }
            .padding(.top)
        }
    }

    @ViewBuilder
    private func permissionStatusRow(permission: Permission, isGranted: Bool) -> some View {
        HStack {
            Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isGranted ? .green : .orange)

            Text(permission.title)
                .font(.subheadline)

            Spacer()

            if !isGranted {
                Button("Grant") {
                    permissionsManager.openSystemPreferences(for: permission)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - Preview

struct FirstRunSetupView_Previews: PreviewProvider {
    static var previews: some View {
        FirstRunSetupView()
    }
}
