# SIH 2026 Project Repository

## 1. Project Information

*   **Project Title:** MediKiosk – Patient Case Taking Software
*   **PS ID:** SIH26047
*   **PS Title:** Patient Case Taking Software
*   **Category:** Software
*   **Theme:** MedTech / BioTech / HealthTech
*   **Team Name:** matriX

## 2. Problem Statement

Doctors face a critical 2-to-5-minute OPD consultation bottleneck, spending excessive time documenting patient histories. Additionally, there is a digital healthcare gap for elderly, rural, and low-literacy patients who struggle with manual registration, leading to fragmented medical records and delayed emergency triage

## 3. Proposed Solution

MediKiosk provides a unified clinical intake platform with multimodal (voice, touch, document) capture for structured pre-consultation history . The system utilizes a multilingual conversational AI engine to dynamically ask adaptive clinical follow-up questions and structure responses . It features an OCR-based document intelligence system to digitize past records and generates a physician-ready clinical summary with automated red-flag detection for immediate triage. 

## 4. Key Features

*   **Universal Login & Interoperability:** Supports 5 login paths (Phone, Aadhaar, ABHA, QR, Ration Card) and features consent-based ABDM/FHIR integration .
*   **Multilingual Voice-Based Intake:** Enables self-service for elderly and low-literacy patients using voice-guided prompts .
*   **AI History Engine:** Dynamically asks adaptive clinical questions using NLP and structures the responses .
*   **Medical Document Intelligence:** Extracts data from prescriptions, lab reports, and discharge summaries using OCR to build a chronological health timeline .
*   **Emergency Red-Flag Detection:** Uses a rule-based clinical decision support engine to flag emergency symptoms like chest pain or breathlessness for priority triage .
*   **Dedicated AYUSH Mode:** Includes a Dashavidha Pariksha module (Prakriti, Vikriti, Agni, Koshtha assessment) mapped to NAMASTE and ICD-11 TM2 terminology .


## 5. Technology Stack

*   **Frontend:** Flutter, Dart 
*   **Backend / API:** Python, FastAPI 
*   **Database:** Postgres, Redis, Google Cloud 
*   **AI/ML:** vLLM, Transformers, Torch, OpenCV-python, PyAudio, PaddleOCR, Sarvam-2B/llama-3 
*   **Deployment:** App release on Play Store and App Store 
*   **API Services:** Bhashini API, vLLM inference API, MSG91/Twilio, ABDM API, API Setu, UIDAI ASA/AUA API 
*   **Add-Ons:** IndicWhisper, IndicTrans2, IndicTTS, CTranslate2, WebRTC VAD, Pydantic, HashiCorp Vault/KMS 

## 6. Architecture

See `docs/architecture.md`.

```text
Patient Entry
  |
  v
Gateway (Identity Verification via OTP/Aadhaar/ABHA/Ration)
  |
  +----> Document Capture (OCR + AI Extraction) ---> Store Documents
  |
  v
Voice Input + AI Processing (Bhashini + vLLM)
  |
  v
Questionnaire (General/AYUSH) + Voice Output
  |
  v
AI Summary Generation <--- (Pulls from Identity DB & Document DB)
  |
  v
Triage Decision
  |
  +----> Emergency ---> Priority Queue Token
  |
  +----> Routine -----> Standard Queue Token
