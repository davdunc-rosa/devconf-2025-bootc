# Presenter Notes: DevConf.us Interactive Workshop

## 🎯 Session Overview
- **Total Time**: 45 minutes
- **Format**: Interactive workshop with 3 hands-on exercises
- **Audience**: Red Hat engineers, container enthusiasts, AI/ML practitioners
- **Goal**: Demonstrate Fedora bootc + RamaLama for enterprise AI infrastructure

## ⏰ Detailed Timing

### Opening (5 minutes)
**Slides**: Title → Interactive Format → Agenda

**Key Points**:
- Welcome to DevConf.us
- This is hands-on - participants will code along
- Emphasize Red Hat/Fedora ecosystem focus
- Quick show of hands: Who has used bootc? RamaLama? LLMs?

**Presenter Actions**:
- Ensure screen sharing is working
- Have terminal ready for demos
- Check that repository is accessible

---

### Enterprise AI Challenge (3 minutes)
**Slides**: Enterprise AI Challenge

**Key Points**:
- Current pain points: vendor lock-in, data privacy, cost escalation
- Red Hat's opportunity in enterprise AI space
- Focus on on-premises, cost-predictable solutions

**Presenter Notes**:
- Keep this brief - audience knows the problems
- Transition quickly to Red Hat's solution

---

### Red Hat's AI Strategy (2 minutes)
**Slides**: Red Hat Enterprise AI Architecture → Red Hat Enterprise AI Stack

**Key Points**:
- OpenShift as the foundation
- Fedora → CentOS Stream → RHEL pipeline
- Container-native approach with Podman/CRI-O

**Presenter Notes**:
- Emphasize the development-to-production pipeline
- This sets up why we're using Fedora bootc

---

### 🛠️ Hands-On Exercise #1: Build Bootable Container (8 minutes)
**Slides**: Hands-On Exercise #1

**Timing Breakdown**:
- Instructions (1 min)
- Participant execution (5 min)
- Troubleshooting/Q&A (2 min)

**Presenter Actions**:
1. **Before starting**: "Everyone open your terminals now"
2. **Walk through each command** slowly
3. **Execute commands yourself** on screen
4. **Monitor chat** for issues
5. **Have helpers** circulate if possible

**Commands to Execute**:
```bash
git clone https://github.com/your-repo/fedora-llm-training
cd fedora-llm-training
podman build -t fedora-llm-bootc:42 -f containers/Containerfile.fedora-llm .
podman images | grep fedora-llm-bootc
```

**Common Issues**:
- Podman not installed → Point to setup script
- Build fails → Check internet connection
- Permission denied → User not in podman group

**Success Criteria**: Participants see their built container image

---

### Bootable Container Concepts (5 minutes)
**Slides**: What are Bootable Containers → Bootable Containers: Core Principles → Fedora bootc for Enterprise AI

**Key Points**:
- Container IS the OS, not just running on OS
- Transactional updates, immutable base
- Perfect for AI workloads - GPU drivers, ML libraries as system components

**Presenter Notes**:
- Use the diagrams to show the difference clearly
- Relate back to what they just built
- Emphasize the "boring" aspect - making AI infrastructure reliable

---

### 🛠️ Hands-On Exercise #2: Cloud-Init Configuration (5 minutes)
**Slides**: Hands-On Exercise #2

**Timing Breakdown**:
- Instructions (1 min)
- Participant execution (3 min)
- Review results (1 min)

**Presenter Actions**:
1. **Emphasize**: Replace "your-aws-key-name" with actual key name
2. **Show the generated file** on screen
3. **Explain key sections** of cloud-init config

**Commands to Execute**:
```bash
export KEY_NAME="your-aws-key-name"
./scripts/generate-user-data.sh
cat infrastructure/user-data-generated.yaml
cloud-init schema --config-file infrastructure/user-data-generated.yaml
```

**Key Teaching Points**:
- Cloud-init handles all the setup automatically
- SSH keys, users, services all configured
- This is what makes bootc cloud-native

**Success Criteria**: Valid cloud-init configuration generated

---

### RamaLama Introduction (3 minutes)
**Slides**: RamaLama: Container-Native LLM Runner

**Key Points**:
- "Make AI more boring" - standardize LLM operations
- Container-like commands for model management
- OpenAI-compatible API
- Perfect fit with Podman ecosystem

**Presenter Notes**:
- Emphasize the container-native approach
- Show how it fits with Red Hat's container strategy
- This is the "secret sauce" that makes LLM management simple

---

### 🛠️ Hands-On Exercise #3: RamaLama Model Management (10 minutes)
**Slides**: Hands-On Exercise #3

**Timing Breakdown**:
- Instructions (1 min)
- Model download (3 min)
- Server setup (2 min)
- API testing (3 min)
- Cleanup (1 min)

**Presenter Actions**:
1. **Warn about download time**: TinyLLama is 600MB
2. **Show API response** on screen
3. **Explain the OpenAI compatibility**
4. **Demonstrate cleanup** is important

**Commands to Execute**:
```bash
pip3 install --user ramalama
ramalama pull tinyllama:1.1b-chat
ramalama list
ramalama serve --port 8080 --host 0.0.0.0 tinyllama:1.1b-chat &
sleep 15
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "tinyllama:1.1b-chat", "messages": [{"role": "user", "content": "Hello! Explain bootable containers in one sentence."}], "max_tokens": 50}' | jq '.choices[0].message.content'
pkill -f ramalama
```

**Success Criteria**: AI generates a response about bootable containers

**Teaching Moment**: Show how the AI response demonstrates the technology working end-to-end

---

### Production Deployment & Wrap-up (4 minutes)
**Slides**: Results & Benefits → Next Steps & Roadmap

**Key Points**:
- Real production benefits: 50% faster deployment, 99.9% consistency
- Clear roadmap to RHEL production
- Community contribution opportunities

**Presenter Notes**:
- Emphasize this isn't just a demo - it's production-ready
- Point to the roadmap for enterprise adoption
- Encourage community participation

---

## 🎤 Presenter Tips

### Before the Session
- [ ] Test all commands on a clean system
- [ ] Verify repository is publicly accessible
- [ ] Have backup slides ready (screenshots of expected outputs)
- [ ] Prepare for common questions (see FAQ below)
- [ ] Test screen sharing and terminal visibility

### During Hands-On Exercises
- **Go slow**: Wait for participants to catch up
- **Repeat commands**: Say them out loud as you type
- **Monitor chat**: Have someone help with questions
- **Show outputs**: Display expected results on screen
- **Be patient**: Not everyone types at the same speed

### Handling Issues
- **Internet problems**: Have offline alternatives ready
- **Permission issues**: Quick sudo/group fixes
- **Build failures**: Point to troubleshooting in guide
- **Time running short**: Skip optional steps, focus on core concepts

### Engagement Techniques
- **Ask questions**: "Who sees the container image now?"
- **Show of hands**: "How many got the API response?"
- **Encourage helping**: "If you're done, help your neighbor"
- **Celebrate success**: "Great! Everyone's AI is working!"

---

## ❓ Anticipated Questions & Answers

### Technical Questions

**Q: Why bootc instead of traditional containers?**
A: Bootc provides immutable infrastructure with atomic updates. For AI workloads, this means consistent environments and reliable rollbacks when model updates fail.

**Q: How does this compare to Docker?**
A: We use Podman (Red Hat's container engine) which is daemonless and more secure. RamaLama works with both Podman and Docker.

**Q: What about GPU support?**
A: The bootc container includes NVIDIA drivers and CUDA toolkit. RamaLama automatically detects and uses GPUs when available.

**Q: Can this run on ARM?**
A: Yes! Fedora bootc supports multi-architecture. We're working on ARM64 builds for edge deployment.

### Business Questions

**Q: Is this production-ready?**
A: Fedora bootc is production-ready for development/testing. For production, wait for RHEL bootc (coming soon) or use current RHEL + containers.

**Q: What's the licensing model?**
A: Everything shown is open source. Red Hat provides enterprise support for RHEL-based deployments.

**Q: How does this integrate with OpenShift?**
A: Bootc containers can run as OpenShift nodes or workloads. We're working on native OpenShift bootc support.

### Troubleshooting

**Q: Build is taking forever**
A: Container builds download ~2GB. On slow connections, this takes time. Consider pre-pulling base images.

**Q: RamaLama model download failed**
A: Models are large (600MB+). Check internet connection and disk space. Try smaller models first.

**Q: Permission denied errors**
A: User needs to be in 'podman' group or use sudo. Run: `sudo usermod -aG podman $USER` then logout/login.

---

## 📋 Success Metrics

### Participant Engagement
- [ ] >80% complete Exercise #1 (container build)
- [ ] >70% complete Exercise #2 (cloud-init)
- [ ] >60% complete Exercise #3 (RamaLama)
- [ ] Active chat participation
- [ ] Questions during Q&A

### Learning Outcomes
- [ ] Participants understand bootc vs traditional containers
- [ ] Participants can explain RamaLama benefits
- [ ] Participants see the Red Hat AI strategy
- [ ] Participants know next steps for adoption

### Follow-up Actions
- [ ] Repository stars/forks increase
- [ ] Community forum discussions
- [ ] Follow-up questions via email/social
- [ ] Requests for deeper technical sessions

---

## 🔗 Quick Links for Presentation

- **Repository**: https://github.com/your-repo/fedora-llm-training
- **Fedora bootc docs**: https://docs.fedoraproject.org/en-US/bootc/
- **RamaLama GitHub**: https://github.com/containers/ramalama
- **Red Hat Developer**: https://developers.redhat.com/
- **DevConf.us**: https://www.devconf.info/us/

**Break a leg! 🚀**