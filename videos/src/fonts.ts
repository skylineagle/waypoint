import { continueRender, delayRender, staticFile } from "remotion";

const faces = [
  { family: "Poppins", weight: "400", file: "Poppins-Regular.ttf" },
  { family: "Poppins", weight: "500", file: "Poppins-Medium.ttf" },
  { family: "Poppins", weight: "600", file: "Poppins-SemiBold.ttf" },
  { family: "Poppins", weight: "700", file: "Poppins-Bold.ttf" },
  { family: "MuseoModerno", weight: "400", file: "MuseoModerno.ttf" },
];

export const fontFaceCss = faces
  .map((face) => `@font-face { font-family: ${face.family}; font-weight: ${face.weight}; font-display: block; src: url(${staticFile(face.file)}) format("truetype"); }`)
  .join("\n");

export const holdUntilFontsLoad = () => {
  const handle = delayRender("Loading fonts");
  Promise.all(faces.map((face) => document.fonts.load(`${face.weight} 40px ${face.family}`))).finally(() => continueRender(handle));
  return handle;
};
