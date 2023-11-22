package de.th.ro.thesis.emanuel.checkprime.controller;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import de.th.ro.thesis.emanuel.checkprime.entitys.ChecktNumber;
import de.th.ro.thesis.emanuel.checkprime.repositorys.ChecktNumberRepository;

import java.util.Optional;

import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(PrimeCheckController.class)
@ActiveProfiles("test")
public class PrimeCheckControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ChecktNumberRepository checktNumberRepository;

    @Test
    public void testCheckPrimeNumberTrue() throws Exception {
        // Mock the repository interaction
        given(checktNumberRepository.findById(anyLong())).willReturn(Optional.empty());
        
        mockMvc.perform(get("/checkIsPrimeNumber")
                        .param("number", "17")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().string("true"));
    }

    @Test
    public void testCheckPrimeNumberFalse() throws Exception {
        // Mock the repository interaction
        given(checktNumberRepository.findById(anyLong())).willReturn(Optional.of(new ChecktNumber(4L, false)));

        mockMvc.perform(get("/checkIsPrimeNumber")
                        .param("number", "4")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().string("false"));
    }

}
