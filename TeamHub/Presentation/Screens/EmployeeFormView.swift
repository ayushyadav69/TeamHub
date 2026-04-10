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
    let onDeletedDismiss: () -> Void
    
    @State private var showImageSourceDialog = false
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showDatePicker = false
    
    init(
        container: AppContainer,
        employee: EmployeeDetail?,
        onDismiss: @escaping () -> Void,
        onDeletedDismiss: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: EmployeeFormViewModel(
                employee: employee,
                prepareEmployeeFormUseCase: container.makePrepareEmployeeFormUseCase(),
                saveEmployeeFormUseCase: container.makeSaveEmployeeFormUseCase(),
                fetchFiltersUseCase: container.makeFetchFiltersUseCase()
            )
        )
        
        self.onDismiss = onDismiss
        self.onDeletedDismiss = onDeletedDismiss
    }
    
    var body: some View {
        
        Form {
            
            Section {
                EmployeeFormImageSectionView(
                    selectedImageData: viewModel.selectedImageData,
                    selectedImageURL: viewModel.selectedImageURL,
                    onChangePhoto: {
                        showImageSourceDialog = true
                    }
                )
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
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
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
                VStack(alignment: .leading, spacing: 4) {
                    TextField("City", text: $viewModel.city)
                    
                    if let error = viewModel.cityError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Country", text: $viewModel.country)
                    
                    if let error = viewModel.countryError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            
            Section("Status") {
                Toggle("Active", isOn: $viewModel.isActive)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Joining Date")
                        
                        Spacer()
                        
                        Text(
                            viewModel.joiningDate?
                                .formatted(date: .abbreviated, time: .omitted)
                            ?? "---"
                        )
                        .foregroundColor(viewModel.joiningDate == nil ? .gray : .primary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if viewModel.joiningDate == nil {
                            viewModel.joiningDate = Date()
                        }
                        showDatePicker = true
                    }
                    
                    if let error = viewModel.joiningDateError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            
            EmployeeFormPhoneSectionView(
                mobiles: $viewModel.mobiles,
                mobileTypes: viewModel.mobileTypes,
                canAddPhone: viewModel.canAddPhone,
                isTypeUsed: viewModel.isTypeUsed,
                numberError: { viewModel.mobileNumberError(for: $0) },
                onDelete: viewModel.removePhone,
                onAddPhone: viewModel.addPhone
            )
        }
        .task {
            await viewModel.loadFilters()
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                onDeletedDismiss()
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePicker(
                "Joining Date",
                selection: Binding(
                    get: { viewModel.joiningDate ?? Date() },
                    set: { viewModel.joiningDate = $0 }
                ),
                in: ...Date.now,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding()
            
            Button("Done") {
                showDatePicker = false
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
        .alert("Error", isPresented: errorAlertIsPresented) {
            if viewModel.canRetryError {
                Button("Retry") {
                    viewModel.retryLastError()
                }
            }
            
            Button("OK", role: .cancel) {
                viewModel.dismissError()
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
            ToolbarItem(placement: .navigationBarTrailing) {
                
                Button("Save") {
                    Task {
                        let success = await viewModel.submit()
                        
                        if success {
                            onDismiss()
                        }
                    }
                }
                .disabled(!viewModel.canSave)
            }
        }
    }
    
    private var errorAlertIsPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissError()
                }
            }
        )
    }
}
