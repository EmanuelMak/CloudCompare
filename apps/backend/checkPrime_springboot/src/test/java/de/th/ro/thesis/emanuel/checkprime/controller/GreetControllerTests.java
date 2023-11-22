package de.th.ro.thesis.emanuel.checkprime.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(GreetController.class)
@ActiveProfiles("test")
public class GreetControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @Test
    public void testGreetingDefault() throws Exception {
        mockMvc.perform(MockMvcRequestBuilders.get("/greeting")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").value("Hello, World!"));
    }

    @Test
    public void testGreetingWithName() throws Exception {
        String testName = "Emanuel";
        mockMvc.perform(MockMvcRequestBuilders.get("/greeting")
                        .param("name", testName)
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").value("Hello, " + testName + "!"));
    }
}
