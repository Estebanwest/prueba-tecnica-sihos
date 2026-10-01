<?php
class Paciente {
    private $conn;
    private $table_name = "pacientes";

    public $id;
    public $nombre;
    public $documento;
    public $correo;
    public $telefono;
    public $fecha_nacimiento;

    public function __construct($db) {
        $this->conn = $db;
    }

    // Obtener todos los pacientes (READ)
    public function obtenerTodos() {
        $query = "SELECT * FROM " . $this->table_name . " ORDER BY id DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt;
    }

    // Crear paciente (CREATE)
    public function crear() {
        $query = "INSERT INTO " . $this->table_name . " 
                  (nombre, documento, correo, telefono, fecha_nacimiento) 
                  VALUES (:nombre, :documento, :correo, :telefono, :fecha_nacimiento)";

        $stmt = $this->conn->prepare($query);

        // Sanitización de datos
        $this->nombre = htmlspecialchars(strip_tags($this->nombre));
        $this->documento = htmlspecialchars(strip_tags($this->documento));
        $this->correo = htmlspecialchars(strip_tags($this->correo));
        $this->telefono = htmlspecialchars(strip_tags($this->telefono));
        $this->fecha_nacimiento = htmlspecialchars(strip_tags($this->fecha_nacimiento));

        // Vinculación de parámetros (Seguridad contra SQL Injection)
        $stmt->bindParam(":nombre", $this->nombre);
        $stmt->bindParam(":documento", $this->documento);
        $stmt->bindParam(":correo", $this->correo);
        $stmt->bindParam(":telefono", $this->telefono);
        $stmt->bindParam(":fecha_nacimiento", $this->fecha_nacimiento);

        return $stmt->execute();
    }

    // Eliminar paciente (DELETE)
    public function eliminar() {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $this->id);
        return $stmt->execute();
    }
}