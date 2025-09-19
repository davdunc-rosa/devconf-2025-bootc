#!/usr/bin/env python3
"""
Basic LLM training script for Fedora containers
Supports fine-tuning of open-source models
"""

import os
import torch
import logging
from transformers import (
    AutoTokenizer,
    AutoModelForCausalLM,
    TrainingArguments,
    Trainer,
    DataCollatorForLanguageModeling
)
from datasets import load_dataset
import argparse

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def setup_model_and_tokenizer(model_name):
    """Load model and tokenizer"""
    logger.info(f"Loading model: {model_name}")
    
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
    
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
        device_map="auto" if torch.cuda.is_available() else None
    )
    
    return model, tokenizer

def prepare_dataset(dataset_name, tokenizer, max_length=512):
    """Prepare training dataset"""
    logger.info(f"Loading dataset: {dataset_name}")
    
    dataset = load_dataset(dataset_name, split="train[:1000]")  # Small subset for testing
    
    def tokenize_function(examples):
        return tokenizer(
            examples["text"],
            truncation=True,
            padding=True,
            max_length=max_length,
            return_tensors="pt"
        )
    
    tokenized_dataset = dataset.map(tokenize_function, batched=True)
    return tokenized_dataset

def main():
    parser = argparse.ArgumentParser(description="Train LLM on Fedora")
    parser.add_argument("--model", default="microsoft/DialoGPT-small", help="Model to fine-tune")
    parser.add_argument("--dataset", default="wikitext", help="Dataset to use")
    parser.add_argument("--output-dir", default="./results", help="Output directory")
    parser.add_argument("--epochs", type=int, default=1, help="Number of training epochs")
    parser.add_argument("--batch-size", type=int, default=4, help="Training batch size")
    
    args = parser.parse_args()
    
    logger.info("Starting LLM training on Fedora")
    logger.info(f"CUDA available: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        logger.info(f"GPU: {torch.cuda.get_device_name()}")
    
    # Setup model and tokenizer
    model, tokenizer = setup_model_and_tokenizer(args.model)
    
    # Prepare dataset
    train_dataset = prepare_dataset(args.dataset, tokenizer)
    
    # Training arguments
    training_args = TrainingArguments(
        output_dir=args.output_dir,
        overwrite_output_dir=True,
        num_train_epochs=args.epochs,
        per_device_train_batch_size=args.batch_size,
        save_steps=500,
        save_total_limit=2,
        prediction_loss_only=True,
        logging_dir=f"{args.output_dir}/logs",
        logging_steps=100,
        warmup_steps=100,
        learning_rate=5e-5,
        fp16=torch.cuda.is_available(),
    )
    
    # Data collator
    data_collator = DataCollatorForLanguageModeling(
        tokenizer=tokenizer,
        mlm=False,
    )
    
    # Initialize trainer
    trainer = Trainer(
        model=model,
        args=training_args,
        data_collator=data_collator,
        train_dataset=train_dataset,
    )
    
    # Start training
    logger.info("Starting training...")
    trainer.train()
    
    # Save model
    logger.info(f"Saving model to {args.output_dir}")
    trainer.save_model()
    tokenizer.save_pretrained(args.output_dir)
    
    logger.info("Training completed!")

if __name__ == "__main__":
    main()