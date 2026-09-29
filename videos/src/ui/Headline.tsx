import type { FC } from "react";
import { colors, dayAccent, fonts, nightAccent } from "../theme";
import { Words } from "./Words";

export type HeadlineProps = { eyebrow: string; line: string; accent: string; at: number; tone?: "night" | "day" };

export const Headline: FC<HeadlineProps> = ({ eyebrow, line, accent, at, tone = "night" }) => {
  const isDay = tone === "day";
  const lineStyle = { fontSize: 100, fontWeight: 700, lineHeight: 1.06, letterSpacing: -3 } as const;
  return (
    <div style={{ position: "absolute", left: 80, right: 60, top: 150, fontFamily: fonts.body, color: isDay ? colors.ink : "#fff" }}>
      <Words text={eyebrow} at={at} style={{ fontFamily: fonts.display, fontSize: 46, color: isDay ? "#4f46e5" : colors.soft, marginBottom: 14 }} />
      <Words text={line} at={at + 0.12} style={lineStyle} />
      <Words
        text={accent}
        at={at + 0.3}
        style={lineStyle}
        wordStyle={{ background: isDay ? dayAccent : nightAccent, WebkitBackgroundClip: "text", color: "transparent", paddingBottom: 8 }}
      />
    </div>
  );
};
