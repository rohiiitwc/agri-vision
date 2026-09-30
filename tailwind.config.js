/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./client/index.html",
    "./client/src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        agri: {
          50: '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
          800: '#166534',
          900: '#14532d',
          950: '#052e16',
        },
        forest: {
          50: '#f4f7f5',
          100: '#e3eae5',
          200: '#c6d6cd',
          300: '#9eb8ab',
          400: '#739584',
          500: '#537a67',
          600: '#3f6050',
          700: '#334e42',
          800: '#2a4037',
          900: '#24352e',
          950: '#121e19',
        },
        amber: {
          ochre: '#d97706',
          soil: '#854d0e',
          harvest: '#f59e0b',
        },
        crimson: {
          warning: '#dc2626',
          alert: '#991b1b',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
