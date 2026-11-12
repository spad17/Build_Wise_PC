(function () {
  function formatPrice(value) {
    if (value === "Цена по запросу") return value;
    return new Intl.NumberFormat("ru-RU", { maximumFractionDigits: 0 }).format(Number(value || 0)) + " ₽";
  }

  function createCard(part) {
    const article = document.createElement("article");
    article.className = "panel live-card";
    const image = document.createElement("img");
    image.className = "live-card-image";
    image.src = part.image_url || "/component-images/catalog-fallback.svg";
    image.alt = `${part.manufacturer} ${part.name}`;
    image.loading = "lazy";
    image.onerror = function () { image.onerror = null; image.src = "/component-images/catalog-fallback.svg"; };
    article.append(image);

    const meta = document.createElement("div");
    meta.className = "live-card-meta";
    meta.textContent = `${part.manufacturer} · ${part.category_name}`;
    article.append(meta);

    const title = document.createElement("h2");
    const link = document.createElement("a");
    link.href = `/components/${part.id}`;
    link.textContent = part.name;
    title.append(link);
    article.append(title);

    const footer = document.createElement("div");
    footer.className = "live-card-footer";
    const price = document.createElement("strong");
    price.textContent = formatPrice(part.price);
    footer.append(price);
    const platform = document.createElement("span");
    platform.textContent = part.platform;
    footer.append(platform);
    article.append(footer);

    if (part.image_credit) {
      const credit = part.source_url ? document.createElement("a") : document.createElement("small");
      credit.className = "live-card-credit";
      credit.textContent = part.image_credit;
      if (part.source_url) {
        credit.href = part.source_url;
        credit.target = "_blank";
        credit.rel = "noopener noreferrer";
      }
      article.append(credit);
    }
    return article;
  }

  function boot() {
    const root = document.querySelector("[data-live-catalog]");
    const grid = document.querySelector("[data-live-grid]");
    if (!root || !grid) return;
    const endpoint = root.dataset.endpoint;
    const refreshMs = Number(root.dataset.refreshMs || 10000);
    const state = root.querySelector("[data-live-state]");
    const indicator = root.querySelector("[data-live-indicator]");
    const updated = root.querySelector("[data-live-updated]");
    const count = document.querySelector("[data-live-count]");
    const search = document.querySelector("[data-live-query]");
    const category = document.querySelector("[data-live-category]");
    const refresh = root.querySelector("[data-live-refresh]");
    let timer;

    function setStatus(text, online) {
      state.textContent = text;
      indicator.classList.toggle("is-online", online);
      indicator.classList.toggle("is-error", !online);
    }

    async function load() {
      const url = new URL(endpoint, window.location.origin);
      if (search.value.trim()) url.searchParams.set("q", search.value.trim());
      if (category.value) url.searchParams.set("category", category.value);
      setStatus("Обновляем…", true);
      try {
        const response = await fetch(url, { headers: { Accept: "application/json" }, cache: "no-store" });
        if (!response.ok) throw new Error("live catalog request failed");
        const payload = await response.json();
        grid.replaceChildren();
        if (!payload.components.length) {
          const empty = document.createElement("div");
          empty.className = "live-empty";
          empty.textContent = "По этому фильтру ничего не найдено.";
          grid.append(empty);
        } else {
          payload.components.forEach((part) => grid.append(createCard(part)));
        }
        grid.setAttribute("aria-busy", "false");
        count.textContent = `${payload.total} позиций`;
        const stamp = payload.generated_at ? new Date(payload.generated_at) : new Date();
        updated.textContent = `Проверено ${stamp.toLocaleTimeString("ru-RU", { hour: "2-digit", minute: "2-digit", second: "2-digit" })}`;
        setStatus("Соединение активно", true);
      } catch (_error) {
        setStatus("Нет соединения", false);
        updated.textContent = "Повторим попытку автоматически";
        grid.setAttribute("aria-busy", "false");
      }
    }

    search.addEventListener("input", function () { clearTimeout(timer); timer = setTimeout(load, 250); });
    category.addEventListener("change", load);
    refresh.addEventListener("click", load);
    load();
    window.setInterval(load, refreshMs);
  }

  document.addEventListener("DOMContentLoaded", boot);
})();
