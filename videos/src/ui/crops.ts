export type CropRegion = { image: string; x: number; y: number; width: number; height: number; radius: number };

export const crops = {
  todayMap: { image: "today-light", x: 44, y: 380, width: 1118, height: 786, radius: 60 },
  todayUpNext: { image: "today-light", x: 146, y: 1300, width: 1016, height: 420, radius: 60 },
  liveActivity: { image: "lock", x: 40, y: 1810, width: 1126, height: 430, radius: 90 },
  widgetMedium: { image: "home-light", x: 80, y: 270, width: 1050, height: 493, radius: 90 },
  widgetSmall: { image: "home-light", x: 80, y: 872, width: 494, height: 494, radius: 90 },
  costsTotal: { image: "menu-dark", x: 44, y: 500, width: 1118, height: 520, radius: 60 },
  costsCurrency: { image: "menu-dark", x: 44, y: 1290, width: 1118, height: 400, radius: 60 },
  receiptMenu: { image: "menu-dark", x: 408, y: 2030, width: 750, height: 300, radius: 70 },
  island: { image: "island", x: 164, y: 42, width: 804, height: 110, radius: 55 },
} satisfies Record<string, CropRegion>;
