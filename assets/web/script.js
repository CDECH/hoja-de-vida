"use strict";

const botonTema = document.querySelector("#tema");

// Flutter también utiliza esta función para cambiar el tema.
window.aplicarTema = function (oscuro) {
  const activarOscuro = Boolean(oscuro);

  document.body.classList.toggle("oscuro", activarOscuro);

  botonTema.textContent = activarOscuro
    ? "Activar tema claro"
    : "Activar tema oscuro";

  botonTema.setAttribute("aria-pressed", String(activarOscuro));

  // Comunica a Flutter el tema elegido desde la página.
  if (window.TemaFlutter) {
    window.TemaFlutter.postMessage(String(activarOscuro));
  }
};

botonTema.addEventListener("click", () => {
  const activarOscuro = !document.body.classList.contains("oscuro");
  window.aplicarTema(activarOscuro);
});

const buscador = document.querySelector("#buscar");
const habilidades = document.querySelectorAll(".habilidades li");
const sinResultados = document.querySelector("#sin-resultados");

buscador.addEventListener("input", () => {
  const texto = buscador.value.trim().toLocaleLowerCase("es");
  let coincidencias = 0;

  habilidades.forEach((habilidad) => {
    const coincide = habilidad.textContent
      .toLocaleLowerCase("es")
      .includes(texto);

    habilidad.hidden = !coincide;

    if (coincide) {
      coincidencias++;
    }
  });

  sinResultados.hidden = coincidencias > 0;
});

const formulario = document.querySelector("#formulario");
const respuesta = document.querySelector("#respuesta");

formulario.addEventListener("submit", (evento) => {
  evento.preventDefault();

  const nombre = document.querySelector("#nombre").value.trim();
  const mensaje = document.querySelector("#mensaje").value.trim();

  if (!nombre || !mensaje) {
    respuesta.textContent =
      "Escribe un nombre y un mensaje que no contengan solo espacios.";
    return;
  }

  respuesta.textContent =
    `Gracias, ${nombre}. Los datos son válidos. ` +
    "Esta demostración no ha enviado ni guardado el mensaje.";
});

window.aplicarTema(false);