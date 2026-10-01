document.addEventListener("DOMContentLoaded", () => {
    const patientForm = document.getElementById("patientForm");
    const patientsTableBody = document.getElementById("patientsTableBody");
    const alertMessage = document.getElementById("alertMessage");

    // Cargar pacientes al iniciar la página
    fetchPatients();

    // Evento de envío del formulario (POST)
    patientForm.addEventListener("submit", async (e) => {
        e.preventDefault();

        const nombre = document.getElementById("nombre").value.trim();
        const documento = document.getElementById("documento").value.trim();
        const correo = document.getElementById("correo").value.trim();
        const telefono = document.getElementById("telefono").value.trim();
        const fecha_nacimiento = document.getElementById("fecha_nacimiento").value;

        // Validación básica en el Frontend
        if (!nombre || !documento || !correo) {
            showAlert("Por favor completa los campos obligatorios.", "danger");
            return;
        }

        const patientData = { nombre, documento, correo, telefono, fecha_nacimiento };

        try {
            const response = await fetch("api.php", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(patientData)
            });

            const result = await response.json();

            if (result.status === "success") {
                showAlert(result.mensaje, "success");
                patientForm.reset();
                fetchPatients(); // Recargar la lista
            } else {
                showAlert(result.mensaje || "Error al registrar.", "danger");
            }
        } catch (error) {
            showAlert("Ocurrió un error al conectar con el servidor.", "danger");
        }
    });

    // Función para obtener pacientes (GET)
    async function fetchPatients() {
        try {
            const response = await fetch("api.php");
            const result = await response.json();

            patientsTableBody.innerHTML = "";

            if (result.status === "success" && result.data.length > 0) {
                result.data.forEach(patient => {
                    const row = document.createElement("tr");
                    row.innerHTML = `
                        <td>${patient.documento}</td>
                        <td>${patient.nombre}</td>
                        <td>${patient.correo}</td>
                        <td>
                            <button class="btn btn-sm btn-danger" onclick="deletePatient(${patient.id})">Eliminar</button>
                        </td>
                    `;
                    patientsTableBody.appendChild(row);
                });
            } else {
                patientsTableBody.innerHTML = `<tr><td colspan="4" class="text-center text-muted">No hay pacientes registrados</td></tr>`;
            }
        } catch (error) {
            showAlert("No se pudieron obtener los datos de los pacientes.", "warning");
        }
    }

    // Función para mostrar mensajes de alerta
    function showAlert(message, type) {
        alertMessage.className = `alert alert-${type}`;
        alertMessage.textContent = message;
        alertMessage.classList.remove("d-none");

        setTimeout(() => {
            alertMessage.classList.add("d-none");
        }, 4000);
    }

    // Exponer la función eliminar globalmente para el botón onclick
    window.deletePatient = async (id) => {
        if (confirm("¿Está seguro de eliminar este paciente?")) {
            try {
                const response = await fetch(`api.php?id=${id}`, { method: "DELETE" });
                const result = await response.json();

                if (result.status === "success") {
                    showAlert(result.mensaje, "success");
                    fetchPatients();
                } else {
                    showAlert(result.mensaje, "danger");
                }
            } catch (error) {
                showAlert("Error al intentar eliminar el paciente.", "danger");
            }
        }
    };
});