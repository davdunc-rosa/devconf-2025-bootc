# Presentation Materials: Fedora LLM Training Platform

This directory contains comprehensive presentation materials for the Fedora LLM Training on AWS EC2 project.

## Files Overview

### 📊 Main Presentation
- **`slides.md`** - Complete slide deck with technical details, architecture diagrams, and implementation walkthrough
  - 15+ slides covering project overview, architecture, implementation, and roadmap
  - Includes code examples and visual diagrams
  - Suitable for technical audiences (30-45 minutes)

### 📋 Executive Summary
- **`executive-summary.md`** - Business-focused overview for stakeholders
  - Strategic benefits and ROI analysis
  - Competitive differentiation
  - Risk mitigation strategies
  - Suitable for executive audiences (10-15 minutes)

### 🔧 Technical Deep Dive
- **`technical-appendix.md`** - Detailed technical specifications and implementation guide
  - Architecture specifications
  - Performance benchmarks
  - Security considerations
  - Troubleshooting guide
  - Reference material for technical teams

## Usage Instructions

### Converting to Presentation Formats

#### Using Marp (Recommended)
```bash
# Install Marp CLI
npm install -g @marp-team/marp-cli

# Convert to HTML slides
marp slides.md --html --output slides.html

# Convert to PDF
marp slides.md --pdf --output slides.pdf

# Convert to PowerPoint
marp slides.md --pptx --output slides.pptx
```

#### Using Pandoc
```bash
# Install Pandoc
# Ubuntu/Debian: sudo apt install pandoc
# macOS: brew install pandoc

# Convert to reveal.js HTML presentation
pandoc slides.md -t revealjs -s -o slides.html

# Convert to PowerPoint
pandoc slides.md -o slides.pptx

# Convert to PDF (requires LaTeX)
pandoc slides.md -t beamer -o slides.pdf
```

#### Using GitPitch (Online)
1. Upload `slides.md` to a GitHub repository
2. Visit `https://gitpitch.com/yourusername/yourrepo`
3. Present directly from the web

### Customization Tips

#### For Different Audiences

**Technical Team Presentation**:
- Use `slides.md` as the main deck
- Include `technical-appendix.md` as reference
- Focus on architecture and implementation slides

**Executive Presentation**:
- Start with `executive-summary.md`
- Use selected slides from `slides.md` (overview, benefits, roadmap)
- Emphasize business value and ROI

**Customer/Partner Presentation**:
- Combine executive summary with demo slides
- Focus on Red Hat partnership value
- Include competitive differentiation

#### Slide Customization

**Adding Your Branding**:
```markdown
<!-- Add to top of slides.md -->
<style>
.slide {
  background-image: url('your-logo.png');
  background-position: top right;
  background-size: 100px;
}
</style>
```

**Custom Themes**:
- Marp: Add `<!-- theme: your-theme -->` at the top
- Reveal.js: Use `--theme` parameter
- PowerPoint: Apply themes after conversion

### Presentation Flow Recommendations

#### 30-Minute Technical Presentation
1. Project Overview (3 min)
2. Architecture & Design (8 min)
3. Implementation Details (10 min)
4. Demo (5 min)
5. Q&A (4 min)

#### 15-Minute Executive Presentation
1. Business Value Proposition (3 min)
2. Technical Highlights (5 min)
3. ROI & Next Steps (4 min)
4. Q&A (3 min)

#### 45-Minute Deep Dive
1. Full slide deck (30 min)
2. Technical appendix walkthrough (10 min)
3. Q&A and discussion (5 min)

## Demo Preparation

### Live Demo Checklist
- [ ] AWS account with appropriate permissions
- [ ] EC2 key pair created and accessible
- [ ] Local environment with Terraform and Podman
- [ ] Sample training data prepared
- [ ] Backup slides in case of connectivity issues

### Demo Script
1. **Infrastructure Deployment** (5 min)
   ```bash
   export KEY_NAME="demo-key"
   ./scripts/deploy-ec2.sh
   ```

2. **Container Build** (3 min)
   ```bash
   ./scripts/build-container.sh
   ```

3. **Training Execution** (2 min)
   ```bash
   # Show training starting
   podman run -it fedora-llm:latest python3 train.py --epochs 1
   ```

### Backup Demo Materials
- Pre-recorded demo video
- Screenshots of key steps
- Sample training outputs and logs
- Performance metrics and graphs

## Additional Resources

### Supporting Materials
- Architecture diagrams (create with draw.io or similar)
- Performance benchmark charts
- Cost analysis spreadsheets
- Security compliance checklists

### Follow-up Materials
- Detailed implementation guide
- Getting started tutorial
- FAQ document
- Contact information for technical support

## Feedback and Updates

### Version Control
- Track presentation versions in git
- Tag releases for major presentations
- Maintain changelog for updates

### Continuous Improvement
- Collect feedback after each presentation
- Update slides based on common questions
- Refresh benchmarks and examples regularly
- Keep competitive analysis current

---

**Ready to present the future of AI with Red Hat technologies!** 🚀