import { Img, staticFile } from "remotion";
import type { FC } from "react";

export type ScreenImageProps = { name: string };

export const ScreenImage: FC<ScreenImageProps> = ({ name }) => (
  <Img src={staticFile(`raw/${name}.png`)} style={{ position: "absolute", inset: 0, width: "100%", height: "100%" }} />
);
