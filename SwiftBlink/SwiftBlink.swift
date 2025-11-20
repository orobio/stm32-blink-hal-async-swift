import _Concurrency

@main
struct Main {
    static func main() async {
        Initialize_Hardware();

        while true {
            print("Hello, world! From Swift!")

            Switch_On_LED()
            HAL_Delay(500)
            Switch_Off_LED()
            HAL_Delay(500)
        }
    }
}
