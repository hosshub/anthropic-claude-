package com.tayyibat.app

import com.tayyibat.app.data.model.FastingType
import com.tayyibat.app.service.FastingCalculator
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDate

class FastingCalculatorTest {
    @Test fun mondayIsSuggested() {
        // 2024-01-01 هو يوم إثنين.
        val monday = LocalDate.of(2024, 1, 1)
        assertTrue(FastingCalculator.suggestedTypes(monday).contains(FastingType.MONDAY))
    }

    @Test fun thursdayIsSuggested() {
        // 2024-01-04 هو يوم خميس.
        val thursday = LocalDate.of(2024, 1, 4)
        assertTrue(FastingCalculator.suggestedTypes(thursday).contains(FastingType.THURSDAY))
    }

    @Test fun upcomingDaysAreNotEmptyOverTwoWeeks() {
        // خلال أسبوعين لا بد من وجود إثنين أو خميس.
        val days = FastingCalculator.upcomingFastingDays(LocalDate.of(2024, 1, 1), 14)
        assertTrue(days.isNotEmpty())
    }
}
