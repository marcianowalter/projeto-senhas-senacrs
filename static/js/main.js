function buscarUltimasSenhas() {
  fetch("/api/senhas")
    .then((response) => response.json())
    .then((senhas) => {
      const lista = document.getElementById("lista-senhas");
      lista.innerHTML = ""; // Limpa a lista atual

      senhas.forEach((senhaObj) => {
        const li = document.createElement("li");

        li.innerHTML = `
<div class="flex mt-12 justify-evenly w-full items-center px-10">
  <input
    id="senha-${senhaObj.id}"
    value="${senhaObj.senha}"
    class="border rounded h-10 px-2 grow ml-4 mr-2"
    type="password"
    readonly
  />
  <div class="flex items-center">
    <button
      class="ml-2 bg-slate-300 rounded h-10 px-3 py-1 hover:bg-slate-400"
      onclick="showSenhaPorId(${senhaObj.id})"
      aria-label="ver senha"
    >
      <span id="senha-icon-${senhaObj.id}" class="font-emoji">visibility</span>
    </button>
    <button
      class="ml-2 bg-slate-300 rounded h-10 px-3 py-1 hover:bg-slate-400"
      onclick="copiarParaAreaDeTransferenciaPorId(${senhaObj.id})"
      aria-label="copiar para área de transferência"
    >
      <span class="font-emoji">content_copy</span>
    </button>
  </div>
</div>
        `.trim();

        lista.appendChild(li);
      });
    })
    .catch((error) => {
      console.error("Erro ao buscar senhas:", error);
    });
}
function showSenha() {
  const input = document.getElementById("senha");
  const senhaIcon = document.getElementById("senha-icon");
  if (input.type === "password") {
    input.type = "text";
    senhaIcon.innerText = "visibility_off";
  } else {
    input.type = "password";
    senhaIcon.innerText = "visibility";
  }
}

function copiarParaAreaDeTransferencia() {
  const senhaElemento = document.getElementById("senha");
  if (senhaElemento && senhaElemento.value) {
    navigator.clipboard.writeText(senhaElemento.value)
      .then(() => alert("Senha copiada!"))
      .catch((err) => alert("Erro ao copiar: " + err));
  }
}

function showSenhaPorId(id) {
  const input = document.getElementById(`senha-${id}`);
  const senhaIcon = document.getElementById(`senha-icon-${id}`);
  if (input.type === "password") {
    input.type = "text";
    senhaIcon.innerText = "visibility_off";
  } else {
    input.type = "password";
    senhaIcon.innerText = "visibility";
  }
}

function copiarParaAreaDeTransferenciaPorId(id) {
  const senhaElemento = document.getElementById(`senha-${id}`);
  if (senhaElemento && senhaElemento.value) {
    navigator.clipboard.writeText(senhaElemento.value)
      .then(() => alert("Senha copiada!"))
      .catch((err) => alert("Erro ao copiar: " + err));
  }
}
