//
//  EmployeeFormView.swift
//  TeamHub
//
//  Created by Ayush yadav on 27/03/26.
//

import SwiftUI

struct EmployeeFormView: View {
    
    @State private var viewModel: EmployeeFormViewModel
    let onDismiss: () -> Void
    
    @State private var showImageSourceDialog = false
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    init(
        container: AppContainer,
        employee: EmployeeDetail?,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: EmployeeFormViewModel(
                employee: employee,
                createEmployeeUseCase: container.makeAddEmployeeUseCase(),
                updateEmployeeUseCase: container.makeUpdateEmployeeUseCase(),
                fetchFiltersUseCase: container.makeFetchFiltersUseCase()
            )
        )
        
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        
        Form {
            
            Section {
                imagePickerView
            }
            
            Section("Basic Info") {
                VStack(alignment: .leading, spacing: 4) {
                    
                    TextField("Name", text: $viewModel.name)
                    
                    if let error = viewModel.nameError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    
                    TextField("Email", text: $viewModel.email)
                    
                    if let error = viewModel.emailError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
            }
            
            Section("Job Info") {
                Picker("Designation", selection: $viewModel.designation) {
                    ForEach(viewModel.designations, id: \.self) { designation in
                        Text(designation).tag(designation)
                    }
                }
                .pickerStyle(.menu)
                Picker("Department", selection: $viewModel.department) {
                    ForEach(viewModel.departments, id: \.self) { department in
                        Text(department).tag(department)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Section("Location") {
                TextField("City", text: $viewModel.city)
                TextField("Country", text: $viewModel.country)
            }
            
            Section("Status") {
                Toggle("Active", isOn: $viewModel.isActive)
            }
            
            Section {
                DatePicker(
                    "Joining Date",
                    selection: $viewModel.joiningDate,
                    in: ...Date.now,
                    displayedComponents: .date
                )
            }
            
            phoneSection
        }
        .onAppear {
            Task {
                await viewModel.loadFilters()
                print("Mobile types:", viewModel.mobileTypes)
            }
        }
        .navigationTitle(viewModel.isEdit ? "Edit Employee" : "Add Employee")
        .confirmationDialog("Select Image", isPresented: $showImageSourceDialog) {
            
            Button("Camera") {
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    sourceType = .camera
                    showImagePicker = true
                } else {
                    print("Camera not available")
                }
            }
            
            Button("Gallery") {
                sourceType = .photoLibrary
                showImagePicker = true
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showImagePicker) {
            
            ImagePicker(sourceType: sourceType) { image in
                
                viewModel.selectedImageData = image.jpegData(compressionQuality: 0.8)
            }
        }
        .toolbar {
            saveButton
        }
    }
    
    var phoneSection: some View {
        
        Section("Phone Numbers") {
            
            ForEach($viewModel.mobiles) { $mobile in
                
                PhoneRowView(
                    mobile: $mobile,
                    mobileTypes: viewModel.mobileTypes,
                    isTypeUsed: viewModel.isTypeUsed,
                    onDelete: {
                        viewModel.removePhone(id: mobile.id!)
                    }
                )
            }
            
            Button("Add Phone") {
                viewModel.addPhone()
            }
        }
    }
    
    var saveButton: some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarTrailing) {
            
            Button("Save") {
                submit()
            }
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
        }
    }
    
    private func submit() {
        
        Task {
            let success = await viewModel.submit()
            
            if success {
                onDismiss()
            }
        }
    }
    
    private var imagePickerView: some View {
        
        VStack {
            
            if let data = viewModel.selectedImageData,
               let uiImage = UIImage(data: data) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())

            } else if let urlString = viewModel.selectedImageURL,
                      let url = URL(string: urlString) {
                
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())

            } else {
                
                Circle()
                    .fill(.secondary.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "camera")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    )
            }
            
            Button("Change Photo") {
                showImageSourceDialog = true
            }
        }
        .frame(maxWidth: .infinity)
    }
}
