import type { FC } from "react";
import { easeIn, progress } from "../motion";
import { colors, fonts, nightAccent } from "../theme";
import { Words } from "../ui/Words";
import { useTime } from "../useTime";
import type { Chapter } from "./cues";

export type ChapterCaptionProps = { chapter: Chapter; left: number; width: number };

export const ChapterCaption: FC<ChapterCaptionProps> = ({ chapter, left, width }) => {
  const time = useTime();
  const { start, end } = chapter.window;
  if (time < start - 0.1 || time > end + 0.1) return null;
  const leave = progress(time, end - 0.45, 0.4, easeIn);
  return (
    <div style={{ position: "absolute", left, width, top: "50%", translate: `0 calc(-50% - ${leave * 24}px)`, opacity: 1 - leave, fontFamily: fonts.body, color: "#fff" }}>
      <Words text={chapter.time} at={start + 0.05} style={{ fontFamily: fonts.display, fontSize: 44, color: colors.soft, marginBottom: 14 }} />
      <Words text={chapter.title} at={start + 0.15} style={{ fontSize: 82, fontWeight: 700, lineHeight: 1.08, letterSpacing: -2.5 }} wordStyle={{ background: nightAccent, WebkitBackgroundClip: "text", color: "transparent", paddingBottom: 8 }} />
      <Words text={chapter.line} at={start + 0.45} stagger={0.035} style={{ marginTop: 22, fontSize: 34, lineHeight: 1.45, color: colors.muted }} />
    </div>
  );
};
