import type { FC } from "react";
import { progress } from "../motion";
import { fonts } from "../theme";
import { useTime } from "../useTime";

export type WordmarkProps = { at: number; size: number };

const LETTERS = "waypoint".split("");

export const Wordmark: FC<WordmarkProps> = ({ at, size }) => {
  const time = useTime();
  return (
    <div style={{ fontFamily: fonts.display, fontSize: size, color: "#fff", letterSpacing: -2, lineHeight: 1 }}>
      {LETTERS.map((letter, index) => {
        const reveal = progress(time, at + index * 0.0625, 0.4);
        return (
          <span
            key={index}
            style={{ display: "inline-block", opacity: reveal, filter: `blur(${(1 - reveal) * 12}px)`, transform: `translateY(${(1 - reveal) * 60}px) scale(${0.7 + 0.3 * reveal})` }}
          >
            {letter}
          </span>
        );
      })}
    </div>
  );
};
