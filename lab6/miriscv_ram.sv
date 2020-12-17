module miriscv_ram
#(
  parameter RAM_SIZE      = 256, // bytes
  parameter RAM_INIT_FILE = ""			//файл для инициализации памяти из файла
)
(
  // clock, reset
  input clk_i,									//тактовый сигнал
  input rst_n_i,								//сброс

  // instruction memory interface
  output logic  [31:0]  instr_rdata_o,	//данные инструкции
  input         [31:0]  instr_addr_i,	//адресс для чтения инструкции

  // data memory interface
  output logic          data_gnt_o,		//сигнализирует, что память начала обрабатывать запрос
  output logic          data_rvalid_o,	// сообщает о появлении ответа от памяти на линиях data_rdata_o
  output logic  [31:0]  data_rdata_o,	//данные памяти
  input                 data_req_i, 	//внешний запрос к памяти
  input                 data_we_i,		//1, если отправлен запрос на запись, 0 – если отправлен запрос на чтение.
  input         [3:0]   data_be_i,		//Для указания на необходимые байты, которые нужно записать
  input         [31:0]  data_addr_i,	//адресс для чтения
  input         [31:0]  data_wdata_i	//данные для записи
);

  reg [31:0]    mem [0:RAM_SIZE/4-1];	//общая память
  reg [31:0]    data_int;

  //Init RAM
  integer ram_index;

  //инициализация памяти
  initial begin
    if(RAM_INIT_FILE != "")
      $readmemh(RAM_INIT_FILE, mem);
    else
      for (ram_index = 0; ram_index < RAM_SIZE/4-1; ram_index = ram_index + 1)
        mem[ram_index] = {32{1'b0}};
  end

	
  //Instruction port 
  //данные из памяти инструкций
  assign instr_rdata_o = mem[(instr_addr_i / 4) % RAM_SIZE];

  //Data port
  assign data_gnt_o = data_req_i;

  always@(posedge clk_i) begin
  
    if	(!rst_n_i) begin			//если сброс...
      data_rvalid_o <= 1'b0;		
      data_rdata_o  <= 32'b0;
    end
    else if	(data_req_i) begin	//если есть запрос к памяти
      data_rdata_o <= mem[(data_addr_i / 4) % RAM_SIZE];
      data_rvalid_o <= 1'b1;		//сообщаем о появлении ответа от памяти на линии data_rdata_o

		//если нужно записать 0-й байт
      if	(data_we_i && data_be_i[0])
        mem [data_addr_i[31:2]] [7:0]  <= data_wdata_i[7:0];

		  //если нужно записать 1-й байт
      if	(data_we_i && data_be_i[1])
        mem [data_addr_i[31:2]] [15:8] <= data_wdata_i[15:8];

		  //если нужно записать 2-й байт
      if	(data_we_i && data_be_i[2])
        mem [data_addr_i[31:2]] [23:16] <= data_wdata_i[23:16];

		  //если нужно записать 3-й байт
      if	(data_we_i && data_be_i[3])
        mem [data_addr_i[31:2]] [31:24] <= data_wdata_i[31:24];

    end else
      data_rvalid_o <= 1'b0;
  end


endmodule
