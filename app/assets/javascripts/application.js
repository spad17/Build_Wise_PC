document.addEventListener("DOMContentLoaded", () => {
  const dialog = document.querySelector("#component-dialog");
  const body = document.querySelector("#component-dialog-body");
  let pending = null;
  document.addEventListener("click", async (event) => {
    const link = event.target.closest("a[data-component-modal]");
    if (link && dialog && typeof dialog.showModal === "function" && !event.ctrlKey && !event.metaKey && !event.shiftKey && event.button === 0) {
      event.preventDefault();
      pending?.abort();
      pending = new AbortController();
      const url = new URL(link.href);
      url.searchParams.set("modal", "1");
      body.textContent = "Загружаем характеристики и отзывы…";
      if (!dialog.open) dialog.showModal();
      try {
        const response = await fetch(url, { signal: pending.signal });
        if (!response.ok) throw new Error("load failed");
        body.innerHTML = await response.text();
      } catch (error) {
        if (error.name !== "AbortError") {
          body.textContent = "Не удалось загрузить. ";
          const fallback = document.createElement("a");
          fallback.href = link.href;
          fallback.textContent = "Открыть страницу комплектующего";
          body.append(fallback);
        }
      }
    }
    if (event.target.closest("[data-close-dialog]") || event.target === dialog) dialog.close();
    if (event.target.closest("[data-print]")) window.print();
  });
  document.addEventListener("submit", (event) => {
    const question = event.submitter?.dataset.confirm;
    if (question && !window.confirm(question)) event.preventDefault();
  });
});
