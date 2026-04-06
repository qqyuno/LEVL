import type { Metadata } from "next";
import { humanoids, robotDogs } from "@/lib/products";
import HomeClient from "@/components/HomeClient";

export const metadata: Metadata = {
  alternates: {
    canonical: "https://robots63.ru",
  },
};

// Server Component — SEO-ready, passes data to the interactive client shell
export default function HomePage() {
  return <HomeClient humanoids={humanoids} robotDogs={robotDogs} />;
}
