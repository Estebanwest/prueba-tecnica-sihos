document.addEventListener("DOMContentLoaded", () => {
    const patientForm = document.getElementById("patientForm");
    const patientsTableBody = document.getElementById("patientsTableBody");
    const alertMessage = document.getElementById("alertMessage");
    const patientId = document.getElementById("patientId");
    const formTitle = document.getElementById("formTitle");
    const btnSubmit = document.getElementById("btnSubmit");
    const btnCancel = document.getElementById("btnCancel");
    const documentoInput = document.getElementById("documento");
    const searchInput = document.getElementById("searchInput");
    const paginationControls = document.getElementById("paginationControls");
    const pageInfo = document.getElementById("pageInfo");

    let patientsCache = [];
    let filteredPatients = [];
    let currentPage = 1;
    const rowsPerPage = 5;

    fetchPatients();

    // Evento de búsqueda en tiempo real
    searchInput.addEventListener("input", () => {
        const query = searchInput.value.toLowerCase().trim();
        filteredPatients = patientsCache.filter(p => 
            p.nombre.toLowerCase().includes(query) || 
            p.correo.toLowerCase().includes(query)
        );
        currentPage = 1;
        renderTable();
    });

    // Validaciones del cliente en JavaScript
    function validateForm(nombre, documento, correo, telefono) {
        let isValid = true;
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        const docRegex = /^[0-9]{6,12}$/;
        const phoneRegex = /^[0-9]{7,10}$/;
        const nameRegex = /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{3,}$/;

        // Validar Nombre
        const nombreEl = document.getElementById("nombre");
        if (!nameRegex.test(nombre)) {
            nombreEl.classList.add("is-invalid");
            isValid = false;
        } else {
            nombreEl.classList.remove("is-invalid");
        }

        // Validar Documento
        if (!docRegex.test(documento)) {
            documentoInput.classList.add("is-invalid");
            isValid = false;
        } else {
            documentoInput.classList.remove("is-invalid");
        }

        // Validar Correo
        const correoEl = document.getElementById("correo");
        if (!emailRegex.test(correo)) {
            correoEl.classList.add("is-invalid");
            isValid = false;
        } else {
            correoEl.classList.remove("is-invalid");
        }

        // Validar Teléfono (si se diligencia)
        const telefonoEl = document.getElementById("telefono");
        if (telefono !== "" && !phoneRegex.test(telefono)) {
            telefonoEl.classList.add("is-invalid");
            isValid = false;
        } else {
            telefonoEl.classList.remove("is-invalid");
        }

        return isValid;
    }

    // Guardar/Editar Paciente
    patientForm.addEventListener("submit", async (e) => {
        e.preventDefault();

        const id = patientId.value;
        const nombre = document.getElementById("nombre").value.trim();
        const documento = documentoInput.value.trim();
        const correo = document.getElementById("correo").value.trim();
        const telefono = document.getElementById("telefono").value.trim();
        const fecha_nacimiento = document.getElementById("fecha_nacimiento").value;

        // Ejecutar validaciones antes de enviar la petición a la API
        if (!validateForm(nombre, documento, correo, telefono)) {
            showAlert("Por favor corrige los campos remarcados en rojo.", "danger");
            return;
        }

        const patientData = { id, nombre, documento, correo, telefono, fecha_nacimiento };
        const isEdit = Boolean(id);
        const method = isEdit ? "PUT" : "POST";

        try {
            const response = await fetch("api.php", {
                method: method,
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(patientData)
            });

            const result = await response.json();

            if (result.status === "success") {
                showAlert(result.mensaje, "success");
                resetForm();
                fetchPatients();
            } else {
                showAlert(result.mensaje || "Error procesando la solicitud.", "danger");
            }
        } catch (error) {
            showAlert("Ocurrió un error al conectar con el servidor.", "danger");
        }
    });

    btnCancel.addEventListener("click", resetForm);

    async function fetchPatients() {
        try {
            const response = await fetch("api.php");
            const result = await response.json();

            if (result.status === "success") {
                patientsCache = result.data;
                filteredPatients = [...patientsCache];
                renderTable();
            }
        } catch (error) {
            showAlert("No se pudieron obtener los datos de los pacientes.", "warning");
        }
    }

    // Renderizar Tabla con Paginación
    function renderTable() {
        patientsTableBody.innerHTML = "";

        if (filteredPatients.length === 0) {
            patientsTableBody.innerHTML = `<tr><td colspan="4" class="text-center text-muted">No se encontraron pacientes</td></tr>`;
            paginationControls.innerHTML = "";
            pageInfo.textContent = "Mostrando 0 registros";
            return;
        }

        const start = (currentPage - 1) * rowsPerPage;
        const end = start + rowsPerPage;
        const paginatedItems = filteredPatients.slice(start, end);

        paginatedItems.forEach(patient => {
            const row = document.createElement("tr");
            row.innerHTML = `
                <td>${patient.documento}</td>
                <td>${patient.nombre}</td>
                <td>${patient.correo}</td>
                <td class="text-center">
                    <button class="btn btn-sm btn-warning me-1" onclick="editPatient(${patient.id})">Editar</button>
                    <button class="btn btn-sm btn-danger" onclick="deletePatient(${patient.id})">Eliminar</button>
                </td>
            `;
            patientsTableBody.appendChild(row);
        });

        renderPagination();
    }

    // Renderizar Botones de Paginación
    function renderPagination() {
        paginationControls.innerHTML = "";
        const totalPages = Math.ceil(filteredPatients.length / rowsPerPage);

        pageInfo.textContent = `Página ${currentPage} de ${totalPages || 1} (${filteredPatients.length} registros)`;

        if (totalPages <= 1) return;

        for (let i = 1; i <= totalPages; i++) {
            const li = document.createElement("li");
            li.className = `page-item ${i === currentPage ? "active" : ""}`;
            li.innerHTML = `<button class="page-link">${i}</button>`;
            li.addEventListener("click", () => {
                currentPage = i;
                renderTable();
            });
            paginationControls.appendChild(li);
        }
    }

    function showAlert(message, type) {
        alertMessage.className = `alert alert-${type} shadow-sm`;
        alertMessage.textContent = message;
        alertMessage.classList.remove("d-none");

        setTimeout(() => {
            alertMessage.classList.add("d-none");
        }, 4000);
    }

    function resetForm() {
        patientForm.reset();
        patientId.value = "";
        documentoInput.disabled = false;
        formTitle.textContent = "Registrar Nuevo Paciente";
        btnSubmit.textContent = "Guardar Paciente";
        btnSubmit.className = "btn btn-primary w-100 py-2 fw-bold";
        btnCancel.classList.add("d-none");

        // Limpiar clases de validación
        document.querySelectorAll(".is-invalid").forEach(el => el.classList.remove("is-invalid"));
    }

    window.editPatient = (id) => {
        const patient = patientsCache.find(p => p.id == id);
        if (patient) {
            patientId.value = patient.id;
            document.getElementById("nombre").value = patient.nombre;
            documentoInput.value = patient.documento;
            documentoInput.disabled = true;
            document.getElementById("correo").value = patient.correo;
            document.getElementById("telefono").value = patient.telefono || "";
            document.getElementById("fecha_nacimiento").value = patient.fecha_nacimiento || "";

            formTitle.textContent = "Editar Paciente";
            btnSubmit.textContent = "Actualizar Paciente";
            btnSubmit.className = "btn btn-success w-100 py-2 fw-bold";
            btnCancel.classList.remove("d-none");
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    };

    window.deletePatient = async (id) => {
        if (confirm("¿Está seguro de eliminar este paciente?")) {
            try {
                const response = await fetch(`api.php?id=${id}`, { method: "DELETE" });
                const result = await response.json();

                if (result.status === "success") {
                    showAlert(result.mensaje, "success");
                    fetchPatients();
                } else {
                    showAlert(result.mensaje || "Error al eliminar paciente.", "danger");
                }
            } catch (error) {
                showAlert("Error al intentar eliminar el paciente.", "danger");
            }
        }
    };
});