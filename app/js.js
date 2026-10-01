$("#btn_gravar").on("click", function () {

    var txt_nome = $("#nome").val();
    var txt_email = $("#email").val();
    var txt_comentario = $("#comentario").val();

    $.ajax({
        url: "incluir.php",
        type: "post",
        data: { nome: txt_nome, email: txt_email, comentario: txt_comentario },
        beforeSend: function () {
            $("#resposta").html("Enviando......");
        }
    }).done(function (e) {
        $("#resposta").html(e);
    }).fail(function () {
        $("#resposta").html("Erro ao enviar os dados.");
    });

});