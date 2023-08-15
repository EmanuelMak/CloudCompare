package de.th.ro.thesis.emanuel.cloudCompare.model;

public class GreetModel {
    private long id;
    private String content;

    // No-argument constructor (required for Jackson)
    public GreetModel() {}

    // Constructor with arguments
    public GreetModel(long id, String content) {  // Note: changed int to long to match the field type
        this.id = id;
        this.content = content;
    }

    // Standard getters and setters
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    // Properly override the toString() method
    @Override
    public String toString() {
        return "ID: " + this.id + " Content: " + this.content;
    }
}
