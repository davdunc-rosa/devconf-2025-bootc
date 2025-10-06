**Workshop Lab 3: Simple Document-Aware Chatbot**

_Texas Linux Festival 2025 - Hands-on Lab (Simplified)_

**Lab Overview**

**Time Required:** 30 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Completed Workshop Labs 1 & 2 (Podman + RamaLama)

**What You'll Learn:**

- Download RamaLama documentation
- Use Docling to process documents into simple text
- Create a basic chatbot that uses document context
- Connect the chatbot to your RamaLama instance

**What You'll Build:**

- Simple document processor
- Basic context-aware chatbot
- Integration with your existing RamaLama setup

**Lab Prerequisites Check**

**From your HOST system, verify Lab 2 completion:**

cd ~/txlf-workshop  
./scripts/workshop-ctl.sh status  
curl -s <http://localhost:8888/v1/models> | grep -i orca  

**If RamaLama API isn't running, start it:**

./scripts/workshop-ctl.sh shell  
\# Inside container:  
ramalama serve orca-mini --host 0.0.0.0 --port 8888 &  

**Section 1: Install Docling and Download Documentation**

**Step 1.1: Access Your Container and Install Docling**

**From HOST system:**

cd ~/txlf-workshop  
./scripts/workshop-ctl.sh shell  

**Inside your AlmaLinux container:**

\# Install Docling (simple installation)  
pip3 install --user docling requests  
<br/>\# Verify installation  
python3 -c "import docling; print('Docling installed successfully')"  
<br/>\# Create directories  
mkdir -p /workshop/{docs,processed-docs}  

**Step 1.2: Download RamaLama Documentation**

**Create simple documentation downloader:**

cat > /workshop/scripts/get_docs.py << 'EOF'  
# !/usr/bin/env python3  
import requests  
import os  
<br/>\# Simple documentation sources  
docs = {  
"README.md": "<https://raw.githubusercontent.com/containers/ramalama/main/README.md>",  
"ramalama-run.md": "<https://raw.githubusercontent.com/containers/ramalama/main/docs/ramalama-run.md>",  
"ramalama-serve.md": "<https://raw.githubusercontent.com/containers/ramalama/main/docs/ramalama-serve.md>"  
}  
<br/>print("Downloading RamaLama documentation...")  
for filename, url in docs.items():  
try:  
response = requests.get(url, timeout=10)  
with open(f"/workshop/docs/{filename}", "w") as f:  
f.write(response.text)  
print(f"✓ Downloaded {filename}")  
except Exception as e:  
print(f"✗ Failed to download {filename}: {e}")  
<br/>print("Documentation download complete!")  
EOF  
<br/>chmod +x /workshop/scripts/get_docs.py  
python3 /workshop/scripts/get_docs.py  
<br/>\# Verify downloads  
ls -la /workshop/docs/  

**Section 2: Simple Document Processing**

**Step 2.1: Process Documents with Docling**

**Create simple document processor:**

cat > /workshop/scripts/process_docs.py << 'EOF'  
# !/usr/bin/env python3  
from docling.document_converter import DocumentConverter  
import os  
<br/>def process_documents():  
print("Processing documents with Docling...")  
<br/>\# Initialize converter  
converter = DocumentConverter()  
<br/>\# Process each document  
all_text = \[\]  
<br/>for filename in os.listdir("/workshop/docs"):  
if filename.endswith(".md"):  
filepath = f"/workshop/docs/{filename}"  
print(f"Processing {filename}...")  
<br/>try:  
\# Convert document  
result = converter.convert(filepath)  
<br/>\# Get clean text  
text = result.document.export_to_markdown()  
<br/>\# Add to collection  
all_text.append(f"=== {filename} ===\\n{text}\\n\\n")  
<br/>print(f"✓ Processed {filename}")  
<br/>except Exception as e:  
print(f"✗ Error processing {filename}: {e}")  
<br/>\# Save combined documentation  
combined_path = "/workshop/processed-docs/ramalama_docs.txt"  
with open(combined_path, "w") as f:  
f.write("".join(all_text))  
<br/>print(f"✓ Combined documentation saved to {combined_path}")  
print(f"✓ Total size: {len(''.join(all_text))} characters")  
<br/>if \__name__ == "\__main_\_":  
process_documents()  
EOF  
<br/>chmod +x /workshop/scripts/process_docs.py  
python3 /workshop/scripts/process_docs.py  
<br/>\# Check the result  
ls -la /workshop/processed-docs/  
head -20 /workshop/processed-docs/ramalama_docs.txt  

**Section 3: Create Simple Context-Aware Chatbot**

**Step 3.1: Build Basic Chatbot**

**Create the chatbot script:**

cat > /workshop/scripts/simple_chatbot.py << 'EOF'  
# !/usr/bin/env python3  
"""  
Simple context-aware chatbot using RamaLama documentation  
"""  
import requests  
import json  
<br/>class SimpleDocBot:  
def \__init_\_(self):  
self.api_url = "<http://localhost:8888>"  
self.docs_path = "/workshop/processed-docs/ramalama_docs.txt"  
self.load_documentation()  
<br/>def load_documentation(self):  
"""Load the processed documentation"""  
try:  
with open(self.docs_path, "r") as f:  
self.documentation = f.read()  
print(f"✓ Loaded documentation ({len(self.documentation)} characters)")  
except Exception as e:  
print(f"✗ Failed to load documentation: {e}")  
self.documentation = ""  
<br/>def find_relevant_context(self, question, max_chars=2000):  
"""Find relevant parts of documentation for the question"""  
question_lower = question.lower()  
<br/>\# Simple keyword matching  
keywords = question_lower.split()  
<br/>\# Split documentation into paragraphs  
paragraphs = self.documentation.split('\\n\\n')  
<br/>\# Score paragraphs by keyword matches  
scored_paragraphs = \[\]  
for para in paragraphs:  
if len(para.strip()) < 20: # Skip very short paragraphs  
continue  
<br/>score = 0  
para_lower = para.lower()  
for keyword in keywords:  
if keyword in para_lower:  
score += para_lower.count(keyword)  
<br/>if score > 0:  
scored_paragraphs.append((score, para))  
<br/>\# Sort by score and take top paragraphs  
scored_paragraphs.sort(reverse=True, key=lambda x: x\[0\])  
<br/>\# Combine top paragraphs up to max_chars  
context = ""  
for score, para in scored_paragraphs:  
if len(context) + len(para) > max_chars:  
break  
context += para + "\\n\\n"  
<br/>return context.strip()  
<br/>def ask_ramalama(self, question, context=""):  
"""Send question with context to RamaLama"""  
<br/>if context:  
system_prompt = f"""You are a helpful assistant that answers questions about RamaLama.  
Use the following documentation context to answer the question accurately:  
<br/>{context}  
<br/>If the context doesn't contain enough information, say so clearly."""  
else:  
system_prompt = "You are a helpful assistant that answers questions about RamaLama."  
<br/>payload = {  
"model": "orca-mini",  
"messages": \[  
{"role": "system", "content": system_prompt},  
{"role": "user", "content": question}  
\],  
"max_tokens": 200,  
"temperature": 0.7  
}  
<br/>try:  
response = requests.post(  
f"{self.api_url}/v1/chat/completions",  
json=payload,  
timeout=30  
)  
response.raise_for_status()  
<br/>data = response.json()  
return data\['choices'\]\[0\]\['message'\]\['content'\]  
<br/>except Exception as e:  
return f"Error: Could not get response from RamaLama API: {e}"  
<br/>def chat(self, question):  
"""Process a question with context"""  
print(f"\\n🔍 Finding relevant documentation...")  
<br/>\# Find relevant context  
context = self.find_relevant_context(question)  
<br/>if context:  
print(f"📚 Found relevant context ({len(context)} characters)")  
print("🤖 Generating answer with documentation context...")  
else:  
print("⚠️ No relevant context found, using general knowledge")  
<br/>\# Get answer from RamaLama  
answer = self.ask_ramalama(question, context)  
<br/>return {  
'question': question,  
'answer': answer,  
'context_found': bool(context),  
'context_length': len(context)  
}  
<br/>def main():  
print("🤠 Simple RamaLama Documentation Chatbot")  
print("Texas Linux Festival 2025")  
print("=" \* 50)  
<br/>\# Initialize bot  
bot = SimpleDocBot()  
<br/>if not bot.documentation:  
print("❌ No documentation loaded. Run process_docs.py first!")  
return  
<br/>print("\\nType your questions about RamaLama, or 'quit' to exit")  
print("Example questions:")  
print("- How do I install RamaLama?")  
print("- What's the difference between run and serve?")  
print("- How do I download models?")  
<br/>while True:  
try:  
question = input("\\n❓ Ask about RamaLama: ").strip()  
<br/>if question.lower() in \['quit', 'exit', 'bye'\]:  
print("👋 Goodbye!")  
break  
<br/>if not question:  
continue  
<br/>\# Get answer  
result = bot.chat(question)  
<br/>print(f"\\n💬 Answer: {result\['answer'\]}")  
<br/>if result\['context_found'\]:  
print(f"📖 (Used {result\['context_length'\]} chars of documentation)")  
<br/>except KeyboardInterrupt:  
print("\\n👋 Goodbye!")  
break  
except Exception as e:  
print(f"❌ Error: {e}")  
<br/>if \__name__ == "\__main_\_":  
main()  
EOF  
<br/>chmod +x /workshop/scripts/simple_chatbot.py  

**Step 3.2: Test the Chatbot**

**Make sure RamaLama is running and test:**

\# Check if RamaLama API is responding  
curl -s <http://localhost:8888/v1/models> | head -3  
<br/>\# If not responding, start it:  
ramalama serve orca-mini --host 0.0.0.0 --port 8888 &  
sleep 3  
<br/>\# Test the chatbot  
python3 /workshop/scripts/simple_chatbot.py  

**Try these questions:**

How do I install RamaLama?  
What is ramalama serve?  
How do I download models?  
What's the difference between run and serve?  
quit  

**Section 4: Improve the Chatbot**

**Step 4.1: Add Better Context Searching**

**Create an improved version:**

cat > /workshop/scripts/better_chatbot.py << 'EOF'  
# !/usr/bin/env python3  
"""  
Improved simple chatbot with better context matching  
"""  
import requests  
import re  
<br/>class BetterDocBot:  
def \__init_\_(self):  
self.api_url = "<http://localhost:8888>"  
self.docs_path = "/workshop/processed-docs/ramalama_docs.txt"  
self.load_documentation()  
<br/>def load_documentation(self):  
"""Load and organize documentation"""  
try:  
with open(self.docs_path, "r") as f:  
content = f.read()  
<br/>\# Split into sections by file  
self.sections = {}  
current_section = "general"  
current_content = \[\]  
<br/>for line in content.split('\\n'):  
if line.startswith('=== ') and line.endswith(' ==='):  
\# Save previous section  
if current_content:  
self.sections\[current_section\] = '\\n'.join(current_content)  
<br/>\# Start new section  
current_section = line.strip('= ')  
current_content = \[\]  
else:  
current_content.append(line)  
<br/>\# Save last section  
if current_content:  
self.sections\[current_section\] = '\\n'.join(current_content)  
<br/>print(f"✓ Loaded {len(self.sections)} documentation sections")  
<br/>except Exception as e:  
print(f"✗ Failed to load documentation: {e}")  
self.sections = {}  
<br/>def find_best_context(self, question, max_length=1500):  
"""Find the best context for a question"""  
question_lower = question.lower()  
<br/>\# Define keyword mappings to sections  
section_keywords = {  
'README.md': \['install', 'setup', 'getting started', 'introduction'\],  
'ramalama-run.md': \['run', 'chat', 'interactive', 'conversation'\],  
'ramalama-serve.md': \['serve', 'server', 'api', 'service', 'endpoint'\]  
}  
<br/>\# Score sections based on question keywords  
section_scores = {}  
<br/>for section_name, content in self.sections.items():  
score = 0  
content_lower = content.lower()  
<br/>\# Boost score if section keywords match question  
for section, keywords in section_keywords.items():  
if section in section_name:  
for keyword in keywords:  
if keyword in question_lower:  
score += 10  
<br/>\# Score based on direct word matches  
question_words = re.findall(r'\\w+', question_lower)  
for word in question_words:  
if len(word) > 3: # Skip very short words  
score += content_lower.count(word) \* 2  
<br/>if score > 0:  
section_scores\[section_name\] = (score, content)  
<br/>\# Get best sections  
if not section_scores:  
return ""  
<br/>\# Sort by score and combine top sections  
sorted_sections = sorted(section_scores.items(), key=lambda x: x\[1\]\[0\], reverse=True)  
<br/>context = ""  
for section_name, (score, content) in sorted_sections:  
if len(context) + len(content) > max_length:  
\# Add partial content if it fits  
remaining = max_length - len(context)  
if remaining > 200: # Only add if meaningful amount fits  
context += content\[:remaining\] + "..."  
break  
context += f"From {section_name}:\\n{content}\\n\\n"  
<br/>return context.strip()  
<br/>def ask_ramalama(self, question, context=""):  
"""Send question to RamaLama with context"""  
<br/>if context:  
system_prompt = f"""You are a helpful assistant answering questions about RamaLama, a tool for managing AI models with containers.  
<br/>Use the following documentation to answer the question:  
<br/>{context}  
<br/>Answer based on the documentation provided. If the documentation doesn't contain the answer, say so."""  
else:  
system_prompt = "You are a helpful assistant answering questions about RamaLama."  
<br/>payload = {  
"model": "orca-mini",  
"messages": \[  
{"role": "system", "content": system_prompt},  
{"role": "user", "content": question}  
\],  
"max_tokens": 250,  
"temperature": 0.7  
}  
<br/>try:  
response = requests.post(  
f"{self.api_url}/v1/chat/completions",  
json=payload,  
timeout=30  
)  
response.raise_for_status()  
<br/>data = response.json()  
return data\['choices'\]\[0\]\['message'\]\['content'\]  
<br/>except Exception as e:  
return f"Error communicating with RamaLama API: {e}"  
<br/>def get_help(self):  
"""Show help information"""  
return """  
🤠 RamaLama Documentation Bot Help  
<br/>Available Commands:  
\- Ask any question about RamaLama  
\- Type 'sections' to see available documentation sections  
\- Type 'help' to see this help  
\- Type 'quit' to exit  
<br/>Example Questions:  
• How do I install RamaLama?  
• What is the difference between ramalama run and ramalama serve?  
• How do I download AI models?  
• What command starts an API server?  
• How do I list my models?  
"""  
<br/>def list_sections(self):  
"""List available documentation sections"""  
if not self.sections:  
return "No documentation sections loaded."  
<br/>result = "📚 Available Documentation Sections:\\n"  
for section_name in self.sections.keys():  
result += f" • {section_name}\\n"  
return result  
<br/>def main():  
print("🤠 Better RamaLama Documentation Bot")  
print("Texas Linux Festival 2025")  
print("=" \* 50)  
<br/>bot = BetterDocBot()  
<br/>if not bot.sections:  
print("❌ No documentation loaded. Run process_docs.py first!")  
return  
<br/>print(bot.get_help())  
<br/>while True:  
try:  
question = input("\\n❓ Ask about RamaLama: ").strip()  
<br/>if question.lower() in \['quit', 'exit', 'bye'\]:  
print("👋 Thanks for using the RamaLama bot!")  
break  
<br/>if question.lower() == 'help':  
print(bot.get_help())  
continue  
<br/>if question.lower() == 'sections':  
print(bot.list_sections())  
continue  
<br/>if not question:  
continue  
<br/>print("🔍 Searching documentation...")  
context = bot.find_best_context(question)  
<br/>if context:  
print(f"📚 Found relevant information ({len(context)} characters)")  
else:  
print("⚠️ No specific documentation found, using general knowledge")  
<br/>print("🤖 Generating answer...")  
answer = bot.ask_ramalama(question, context)  
<br/>print(f"\\n💬 {answer}")  
<br/>except KeyboardInterrupt:  
print("\\n👋 Goodbye!")  
break  
except Exception as e:  
print(f"❌ Error: {e}")  
<br/>if \__name__== "\__main_\_":  
main()  
EOF  
<br/>chmod +x /workshop/scripts/better_chatbot.py  

**Step 4.2: Test the Improved Chatbot**

**Run the better version:**

python3 /workshop/scripts/better_chatbot.py  

**Try these questions:**

help  
sections  
How do I install RamaLama?  
What does ramalama serve do?  
How do I start a chat session?  
What models can I download?  
quit  

**Section 5: Create Management Scripts**

**Step 5.1: Create Simple Management Script**

**Create a script to manage the whole system:**

cat > /workshop/scripts/docbot_manager.sh << 'EOF'  
# !/bin/bash  
<br/>echo "🤠 RamaLama Documentation Bot Manager"  
echo "Texas Linux Festival 2025"  
echo "=================================="  
<br/>case "\$1" in  
setup)  
echo "Setting up documentation bot..."  
echo "1. Downloading documentation..."  
python3 /workshop/scripts/get_docs.py  
echo "2. Processing with Docling..."  
python3 /workshop/scripts/process_docs.py  
echo "3. Starting RamaLama API..."  
ramalama serve orca-mini --host 0.0.0.0 --port 8888 &  
sleep 3  
echo "✅ Setup complete! Run './docbot_manager.sh chat' to start chatbot"  
;;  
<br/>chat)  
echo "Starting documentation chatbot..."  
if curl -s <http://localhost:8888/v1/models> >/dev/null 2>&1; then  
python3 /workshop/scripts/better_chatbot.py  
else  
echo "❌ RamaLama API not running. Run './docbot_manager.sh setup' first"  
fi  
;;  
<br/>simple)  
echo "Starting simple chatbot..."  
if curl -s <http://localhost:8888/v1/models> >/dev/null 2>&1; then  
python3 /workshop/scripts/simple_chatbot.py  
else  
echo "❌ RamaLama API not running. Run './docbot_manager.sh setup' first"  
fi  
;;  
<br/>status)  
echo "=== System Status ==="  
echo "Documentation files: \$(ls /workshop/docs/\*.md 2>/dev/null | wc -l)"  
echo "Processed docs: \$(ls /workshop/processed-docs/ 2>/dev/null | wc -l)"  
<br/>if curl -s <http://localhost:8888/v1/models> >/dev/null 2>&1; then  
echo "RamaLama API: ✅ Running"  
else  
echo "RamaLama API: ❌ Not running"  
fi  
<br/>if \[ -f "/workshop/processed-docs/ramalama_docs.txt" \]; then  
size=\$(wc -c < /workshop/processed-docs/ramalama_docs.txt)  
echo "Knowledge base: ✅ Ready (\$size bytes)"  
else  
echo "Knowledge base: ❌ Missing"  
fi  
;;  
<br/>clean)  
echo "Cleaning up..."  
pkill -f "ramalama serve" || echo "No API server to stop"  
rm -rf /workshop/docs/\* /workshop/processed-docs/\*  
echo "✅ Cleanup complete"  
;;  
<br/>\*)  
echo "Usage: \$0 {setup|chat|simple|status|clean}"  
echo ""  
echo "Commands:"  
echo " setup - Download docs, process with Docling, start API"  
echo " chat - Start the improved chatbot"  
echo " simple - Start the simple chatbot"  
echo " status - Check system status"  
echo " clean - Clean up all files and stop services"  
;;  
esac  
EOF  
<br/>chmod +x /workshop/scripts/docbot_manager.sh  

**Step 5.2: Test the Complete System**

**Run the full setup:**

cd /workshop  
./scripts/docbot_manager.sh status  
./scripts/docbot_manager.sh setup  
./scripts/docbot_manager.sh status  
./scripts/docbot_manager.sh chat  

**Lab Completion Checklist**

**Verify you have completed all sections:**

- \[ \] **Docling installed** in your AlmaLinux container
- \[ \] **Documentation downloaded** from RamaLama GitHub
- \[ \] **Documents processed** with Docling into simple text
- \[ \] **Simple chatbot** working with basic context
- \[ \] **Improved chatbot** with better context matching
- \[ \] **Management script** to control the whole system
- \[ \] **Integration tested** with your RamaLama API

**Final Test Commands:**

\# These should all work:  
./scripts/docbot_manager.sh status  
./scripts/docbot_manager.sh chat  
\# Try asking: "How do I install RamaLama?"  

_Happy chatbot building! You've created your first document-aware AI at the Texas Linux Festival!_

