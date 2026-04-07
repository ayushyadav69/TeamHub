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
    @State private var showDatePicker = false
    
    init(
        container: AppContainer,
        employee: EmployeeDetail?,
        onDismiss: @escaping () -> Void
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
            }
            
            EmployeeFormPhoneSectionView(
                mobiles: $viewModel.mobiles,
                mobileTypes: viewModel.mobileTypes,
                canAddPhone: viewModel.canAddPhone,
                isTypeUsed: viewModel.isTypeUsed,
                onDelete: viewModel.removePhone,
                onAddPhone: viewModel.addPhone
            )
        }
        .task {
            await viewModel.loadFilters()
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
            ToolbarItem(placement: .navigationBarTrailing) {
                
                Button("Save") {
                    Task {
                        let success = await viewModel.submit()
                        
                        if success {
                            onDismiss()
                        }
                    }
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
            }
        }
    }
}
