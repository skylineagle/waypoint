const defaultDwellSeconds = 6;
const prefersReducedMotion = matchMedia("(prefers-reduced-motion: reduce)").matches;

document.documentElement.classList.add("js");

function revealOnEntry() {
  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      }
    },
    { rootMargin: "0px 0px -12% 0px" },
  );
  document.querySelectorAll(".reveal, .reveal-tile, .reveal-rise").forEach((element) => observer.observe(element));
}

function setActive(elements: ArrayLike<Element>, activeIndex: number) {
  Array.from(elements).forEach((element, index) => element.classList.toggle("is-active", index === activeIndex));
}

function syncStoryPhone(story: HTMLElement) {
  const chapters = story.querySelectorAll<HTMLElement>("[data-chapter]");
  const screens = story.querySelectorAll(".story-phone > img");
  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        const index = Number((entry.target as HTMLElement).dataset.chapter);
        setActive(chapters, index);
        setActive(screens, index);
      }
    },
    { rootMargin: "-50% 0px -50% 0px" },
  );
  chapters.forEach((chapter) => observer.observe(chapter));
}

function runGallery(gallery: HTMLElement) {
  const track = gallery.querySelector<HTMLElement>("[data-gallery-track]")!;
  const dots = gallery.querySelector<HTMLElement>("[data-gallery-dots]")!;
  const playButton = gallery.querySelector<HTMLButtonElement>("[data-gallery-play]")!;
  const items = Array.from(track.children) as HTMLElement[];
  let currentIndex = -1;

  const dotButtons = items.map((item, index) => {
    const dot = document.createElement("button");
    dot.type = "button";
    dot.className = "gallery-dot";
    dot.setAttribute("role", "tab");
    dot.setAttribute("aria-label", item.querySelector(".gallery-caption")?.textContent ?? `Highlight ${index + 1}`);
    dot.addEventListener("click", () => scrollToItem(index));
    dots.append(dot);
    return dot;
  });

  function scrollToItem(index: number) {
    const item = items[index];
    track.scrollTo({ left: item.offsetLeft - (track.clientWidth - item.clientWidth) / 2 });
  }

  function makeCurrent(index: number) {
    if (index === currentIndex) return;
    currentIndex = index;
    items.forEach((item, itemIndex) => {
      const isCurrent = itemIndex === index;
      item.classList.toggle("is-current", isCurrent);
      dotButtons[itemIndex].setAttribute("aria-selected", String(isCurrent));
      const video = item.querySelector("video");
      if (!video) return;
      if (isCurrent && !gallery.hasAttribute("data-paused")) {
        video.currentTime = 0;
        video.play().catch(() => {});
      } else {
        video.pause();
      }
    });
    gallery.style.setProperty("--dwell", `${items[index].dataset.dwell ?? defaultDwellSeconds}s`);
  }

  const itemObserver = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) makeCurrent(items.indexOf(entry.target as HTMLElement));
      }
    },
    { root: track, threshold: 0.6 },
  );
  items.forEach((item) => itemObserver.observe(item));

  dots.addEventListener("animationend", () => scrollToItem((currentIndex + 1) % items.length));

  new IntersectionObserver(([entry]) => gallery.toggleAttribute("data-offscreen", !entry.isIntersecting), {
    threshold: 0.35,
  }).observe(gallery);

  function setPaused(paused: boolean) {
    gallery.toggleAttribute("data-paused", paused);
    playButton.setAttribute("aria-label", paused ? "Play highlights" : "Pause highlights");
    const video = items[currentIndex]?.querySelector("video");
    if (!video) return;
    if (paused) video.pause();
    else video.play().catch(() => {});
  }

  playButton.addEventListener("click", () => setPaused(!gallery.hasAttribute("data-paused")));
  makeCurrent(0);
  if (prefersReducedMotion) setPaused(true);
}

revealOnEntry();
document.querySelectorAll<HTMLElement>("[data-story]").forEach(syncStoryPhone);
document.querySelectorAll<HTMLElement>("[data-gallery]").forEach(runGallery);
