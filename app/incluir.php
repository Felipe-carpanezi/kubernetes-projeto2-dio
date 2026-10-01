<?php
include 'conexao.php';

$id = rand(1, 999);
$nome = $_POST["nome"] ?? "";
$email = $_POST["email"] ?? "";
$comentario = $_POST["comentario"] ?? "";

$stmt = $link->prepare("INSERT INTO mensagens (id, nome, email, comentario) VALUES (?, ?, ?, ?)");
$stmt->bind_param("isss", $id, $nome, $email, $comentario);

if ($stmt->execute()) {
    echo "Dados salvos com sucesso!";
} else {
    echo "Erro: " . $stmt->error;
}

$stmt->close();
$link->close();
?>