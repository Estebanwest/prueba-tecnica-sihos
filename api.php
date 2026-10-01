<?php
header("Content-Type: application/json");
require_once 'controllers/UserController.php';

$controller = new UserController();
$metodo = $_SERVER['REQUEST_METHOD'];

switch ($metodo) {
    case 'GET':
        $controller->listar();
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);
        $controller->registrar($data);
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"), true);
        $controller->actualizar($data);
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? null;
        if ($id) {
            $controller->eliminar($id);
        } else {
            echo json_encode(["status" => "error", "mensaje" => "ID requerido"]);
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(["mensaje" => "Método no permitido"]);
        break;
}