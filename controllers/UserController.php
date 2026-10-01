<?php
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../models/Paciente.php';

class UserController {
    private $db;
    private $paciente;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
        $this->paciente = new Paciente($this->db);
    }

    private function validarEmail($email) {
        return filter_var($email, FILTER_VALIDATE_EMAIL);
    }

    public function listar() {
        $stmt = $this->paciente->obtenerTodos();
        $pacientes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(["status" => "success", "data" => $pacientes]);
    }

    public function registrar($data) {
        if (empty($data['nombre']) || empty($data['documento']) || empty($data['correo'])) {
            echo json_encode(["status" => "error", "mensaje" => "Campos obligatorios incompletos"]);
            return;
        }

        if (!$this->validarEmail($data['correo'])) {
            echo json_encode(["status" => "error", "mensaje" => "Formato de correo electrónico inválido"]);
            return;
        }

        $this->paciente->nombre = $data['nombre'];
        $this->paciente->documento = $data['documento'];
        $this->paciente->correo = $data['correo'];
        $this->paciente->telefono = $data['telefono'] ?? '';
        $this->paciente->fecha_nacimiento = $data['fecha_nacimiento'] ?? null;

        if ($this->paciente->crear()) {
            echo json_encode(["status" => "success", "mensaje" => "Paciente creado correctamente"]);
        } else {
            echo json_encode(["status" => "error", "mensaje" => "Error al registrar paciente"]);
        }
    }

    public function actualizar($data) {
        if (empty($data['id']) || empty($data['nombre']) || empty($data['correo'])) {
            echo json_encode(["status" => "error", "mensaje" => "Datos incompletos para actualizar"]);
            return;
        }

        if (!$this->validarEmail($data['correo'])) {
            echo json_encode(["status" => "error", "mensaje" => "Formato de correo electrónico inválido"]);
            return;
        }

        $this->paciente->id = $data['id'];
        $this->paciente->nombre = $data['nombre'];
        $this->paciente->correo = $data['correo'];
        $this->paciente->telefono = $data['telefono'] ?? '';
        $this->paciente->fecha_nacimiento = $data['fecha_nacimiento'] ?? null;

        if ($this->paciente->actualizar()) {
            echo json_encode(["status" => "success", "mensaje" => "Paciente actualizado correctamente"]);
        } else {
            echo json_encode(["status" => "error", "mensaje" => "Error al actualizar paciente"]);
        }
    }

    public function eliminar($id) {
        $this->paciente->id = $id;
        if ($this->paciente->eliminar()) {
            echo json_encode(["status" => "success", "mensaje" => "Paciente eliminado correctamente"]);
        } else {
            echo json_encode(["status" => "error", "mensaje" => "Error al eliminar paciente"]);
        }
    }
}