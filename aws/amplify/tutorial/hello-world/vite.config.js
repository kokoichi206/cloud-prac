import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import json from "@rollup/plugin-json";

export default defineConfig({
    plugins: [vue(), json()],
});
