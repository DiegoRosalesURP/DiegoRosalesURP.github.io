import { describe, it, expect, beforeAll } from 'vitest'
import { readFileSync, existsSync } from 'node:fs'
import { JSDOM } from 'jsdom'

const SITIO = '_site'
let doc

beforeAll(() => {
  const html = readFileSync(`${SITIO}/index.html`, 'utf-8')
  doc = new JSDOM(html).window.document
})

describe('index.html', () => {
  it('tiene un título', () => {
    expect(doc.title.trim()).not.toBe('')
  })

  it('muestra el nombre correcto en el h1', () => {
    expect(doc.querySelector('h1')?.textContent)
      .toContain('Diego Alejandro Rosales Enciso')
  })

  it('usa idioma español', () => {
    expect(doc.documentElement.lang).toBe('es')
  })

  it('tiene configuración UTF-8', () => {
    expect(doc.querySelector('meta[charset="UTF-8"]')).not.toBeNull()
  })

  it('tiene meta viewport', () => {
    expect(doc.querySelector('meta[name="viewport"]')).not.toBeNull()
  })

  it('tiene un único h1', () => {
    expect(doc.querySelectorAll('h1')).toHaveLength(1)
  })

  it('contiene las secciones principales', () => {
    for (const id of ['sobre-mi', 'habilidades', 'proyectos', 'contacto']) {
      expect(doc.getElementById(id), `falta #${id}`).not.toBeNull()
    }
  })

  it('contiene el libro de visitas', () => {
    expect(doc.getElementById('libro-de-visitas')).not.toBeNull()
  })

  it('el formulario del libro de visitas tiene nombre y mensaje', () => {
    expect(doc.querySelector('input[name="nombre"]')).not.toBeNull()
    expect(doc.querySelector('textarea[name="mensaje"]')).not.toBeNull()
  })

  it('el mensaje permite como máximo 280 caracteres', () => {
    expect(doc.querySelector('textarea[name="mensaje"]')
      ?.getAttribute('maxlength')).toBe('280')
  })

  it('todos los archivos locales utilizados existen', () => {
    const rutas = [
      ...doc.querySelectorAll('script[src], link[rel="stylesheet"], img[src]')
    ]
      .map((el) => el.getAttribute('src') ?? el.getAttribute('href'))
      .filter((ruta) => ruta && !/^(https?:)?\/\//.test(ruta))

    for (const ruta of rutas) {
      expect(existsSync(`${SITIO}/${ruta}`), `falta ${ruta}`).toBe(true)
    }
  })

  it('no contiene referencias a localhost', () => {
    const html = readFileSync(`${SITIO}/index.html`, 'utf-8')
    expect(html).not.toContain('localhost')
  })
})

describe('el sitio publicado', () => {
  it('no incluye archivos internos del repositorio', () => {
    for (const interno of [
      'compose.yaml',
      '.env.example',
      'api',
      'db',
      'tests'
    ]) {
      expect(
        existsSync(`${SITIO}/${interno}`),
        `${interno} no debería publicarse`
      ).toBe(false)
    }
  })
})