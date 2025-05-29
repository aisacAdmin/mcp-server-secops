MCP Server SecOps

MCP Server SecOps es un servidor basado en el protocolo Model Context Protocol (MCP) que integra múltiples herramientas de ciberseguridad ofensiva. Su objetivo es permitir que agentes LLM y sistemas automatizados puedan ejecutar escaneos, descubrir vulnerabilidades y analizar objetivos con un solo comando, facilitando flujos automatizados de evaluación de seguridad.

Este servidor está diseñado para ser una base extensible, enfocada en startups, investigadores y equipos DevSecOps que desean integrar capacidades ofensivas directamente en sus pipelines o entornos de desarrollo, a través de un estándar interoperable como MCP.

⸻

⚠️ Advertencia de Seguridad

Este servidor ejecuta herramientas reales de pentesting como nmap, sqlmap, ffuf, amass, entre otras. Ejecutarlas sin autorización contra infraestructuras externas puede ser ilegal.

Recomendamos usarlas únicamente en entornos controlados o con permiso explícito.

⸻

🚀 Características Principales
	•	✅ Compatible con MCP (Model Context Protocol)
	•	🔧 Registro dinámico de herramientas según parámetros
	•	📦 Dockerfile preparado para instalación con dependencias del sistema
	•	🤖 Diseñado para integración con LLMs como Claude, ChatGPT o agentes personalizados
	•	📂 Estructura modular para agregar nuevas herramientas ofensivas fácilmente
	•	📊 Respuestas estructuradas en JSON, listas para análisis automático o dashboards

⸻

🛠️ Herramientas Incluidas

Cada herramienta está disponible como un comando MCP que acepta parámetros definidos y devuelve resultados procesados:
	•	nmap: Escaneo de puertos y detección de servicios
	•	ffuf: Fuzzing de rutas web
	•	wfuzz: Fuzzing web avanzado con filtros
	•	sqlmap: Inyección SQL automatizada y toma de bases de datos
	•	nuclei: Scanner de vulnerabilidades por plantillas YAML
	•	httpx: Probing HTTP con múltiples opciones
	•	hashcat: Ataques de fuerza bruta para hash
	•	subfinder: Descubrimiento pasivo de subdominios
	•	tlsx: Información de certificados SSL/TLS
	•	xsstrike: Auditoría XSS con detección avanzada
	•	amass: Mapeo de superficie de ataque
	•	dirsearch: Descubrimiento de directorios en aplicaciones web
	•	ipinfo: Geolocalización y ASN de direcciones IP

Cada una puede invocarse desde el servidor MCP o directamente como parte de flujos n8n, scripts automatizados o agentes conversacionales.

⸻

🔧 Instalación

Opción 1: con uv (recomendado)

uv venv
uv sync
uv run mcp-server-secops

Opción 2: con pip

pip install -e .
python -m mcp_server_secops.server

Opción 3: con Docker

El Dockerfile incluido instala todas las herramientas externas necesarias (como nmap, sqlmap, ffuf, etc.). Puedes construir la imagen así:

docker build -t mcp-secops .
docker run --rm -it mcp-secops


⸻

🧠 Uso

Ejecutar el servidor:

uvx mcp-server-secops

Por defecto se registran todas las herramientas. También puedes especificarlas:

uvx mcp-server-secops --tools nmap nuclei sqlmap --verbose

Probar con MCP Inspector

npx @modelcontextprotocol/inspector uvx mcp-server-secops

Este comando abre una interfaz para interactuar directamente con las herramientas como si fueras un LLM.

⸻

⚙️ Integración con VS Code o Claude

Puedes configurar tu .vscode/mcp.json así:

{
  "mcpServers": {
    "secops": {
      "command": "uvx",
      "args": ["mcp-server-secops"]
    }
  }
}

Esto permite que la herramienta sea llamada desde entornos como Claude Desktop o desde el plugin de VS Code.

⸻

🧩 Personalización

Puedes extender el servidor agregando scripts en tools/ y registrándolos en server.py. Cada wrapper convierte una herramienta CLI en un recurso MCP autocontenido.

Además puedes:
	•	Cambiar user-agent o proxy con flags --user-agent y --proxy-url
	•	Ignorar robots.txt si tu herramienta accede a contenido web restringido
	•	Añadir nuevos flujos complejos orquestando múltiples herramientas en un solo endpoint

⸻

🛠 Ejemplo de herramienta: Nmap

Puedes invocar el recurso nmap con los siguientes parámetros:

{
  "target": "scanme.nmap.org",
  "ports": "22,80",
  "scan_type": "sV"
}

Y obtendrás algo como:

{
  "success": true,
  "target": "scanme.nmap.org",
  "results": {
    "xml_output": "..."
  }
}


⸻

🤝 Contribuciones

Este proyecto está abierto a contribuciones. Puedes aportar:
	•	Wrappers nuevos
	•	Mejoras en parseo de resultados
	•	Automatización de flujos
	•	Mejoras en el sistema de configuración o logging

Puedes tomar inspiración del repositorio oficial de MCP: https://github.com/modelcontextprotocol/servers

⸻

📜 Licencia

Este proyecto se publica bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.