package com.th.ro.emanuel.thesis.camelcase;


public class CamelCaseConverter {

    public static String toCamelCase(String text) {
        String[] words = text.split("[\\s_-]+");  // Split by space, dash, or underscore

        StringBuilder camelCaseBuilder = new StringBuilder();

        for (int i = 0; i < words.length; i++) {
            String word = words[i].replaceAll("[^a-zA-Z0-9]", "");  // Remove special characters
            if (i == 0) {
                camelCaseBuilder.append(word.toLowerCase());
            } else {
                camelCaseBuilder.append(capitalizeFirstLetter(word));
            }
        }

        return camelCaseBuilder.toString();
    }

    private static String capitalizeFirstLetter(String word) {
        if (word.isEmpty()) {
            return "";
        }
        return word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase();
    }
}