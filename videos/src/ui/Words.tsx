import type { CSSProperties, FC } from "react";
import { progress } from "../motion";
import { useTime } from "../useTime";

export type WordsProps = { text: string; at: number; stagger?: number; style?: CSSProperties; wordStyle?: CSSProperties };

export const Words: FC<WordsProps> = ({ text, at, stagger = 0.07, style, wordStyle }) => {
  const time = useTime();
  return (
    <div style={style}>
      {text.split(" ").map((word, index) => {
        const reveal = progress(time, at + index * stagger, 0.45);
        return (
          <span
            key={index}
            style={{
              display: "inline-block",
              marginRight: "0.26em",
              opacity: reveal,
              filter: `blur(${(1 - reveal) * 10}px)`,
              transform: `translateY(${(1 - reveal) * 0.45}em)`,
              ...wordStyle,
            }}
          >
            {word}
          </span>
        );
      })}
    </div>
  );
};
