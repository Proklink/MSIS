module LSU
(
 input clk_i,
 input arstn_i,
 
 // memory protocol
 input 			data_gnt_i,  		//сигнализирует, что память начала обрабатывать запрос
 input 			data_rvalid_i,		// сообщает о появлении ответа от памяти на линиях data_rdata_i //активен на протяжении только одного такта																				
 input [31:0] 	data_rdata_i,		// содержит данные из ячейки памяти на момент принятия запроса
 output reg			data_req_o,			//сообщает памяти о наличии запроса.
 output reg			data_we_o,			// 1, если отправлен запрос на запись, 0 – если отправлен запрос на чтение.
 output reg [3:0] 	data_be_o, 			//Для указания на необходимые байты, которые нужно записать
 output reg [31:0] data_addr_o,		//адрес слова
 output reg [31:0] data_wdata_o,		//Данные для записи
 
 
 // core protocol
 input [31:0] 	lsu_addr_i,			//адрес ячейки памяти, к которой будет произведено обращение
 input 			lsu_we_i,			//Если процессор собирается записывать в память
 input [2:0] 	lsu_size_i, 		//Для выбора разрядности (mem_size_o)
 input [31:0] 	lsu_data_i,			// данные, которые следует записать
 input 			lsu_req_i,			//Намеренье процессора обратиться к памяти
 output reg			lsu_stall_req_o,	// поднятый сигнал  сообщит блоку управления, что работа ядра должна быть приостановлена, пока запрос не будет выполнен.
 output reg [31:0] lsu_data_o			//считанные данные для процессора
);


always @ (*) begin
	lsu_stall_req_o = lsu_req_i && !data_rvalid_i;
	data_req_o = lsu_stall_req_o;
	data_we_o = lsu_we_i;
	data_addr_o = lsu_addr_i;
	
	
	
	if (lsu_req_i) 
		if (lsu_we_i) 
			begin
			if ((lsu_size_i == 3'd0) || (lsu_size_i == 3'd4 )) 
				begin
					data_wdata_o = {4{lsu_data_i[7:0]}};
					case (lsu_addr_i[1:0])
						2'b00 : 
							begin
								data_be_o = 4'b0001;
							end
						2'b01 : 
							begin
								data_be_o = 4'b0010;
							end
						2'b10 : 
							begin
								data_be_o = 4'b0100;
							end
						2'b11 : 
							begin
								data_be_o = 4'b0001;
							end
					endcase
				end
			if ((lsu_size_i == 3'd1 ) || (lsu_size_i == 3'd5  )) 
				begin
					data_wdata_o = {2{lsu_data_i[15:0]}};
					case (lsu_addr_i[1:0])
						2'b00 : 
							begin
								data_be_o = 4'b0011;
							end
						2'b10 : 
							begin
								data_be_o = 4'b1100;
							end
					endcase
				end
			if (lsu_size_i == 3'd2)	
				if (lsu_addr_i[1:0] == 2'b0)
					begin
						data_be_o = 4'b0001;
						data_wdata_o = lsu_data_i;
					end
			end
		else 
		begin
			data_be_o = 0;
			data_wdata_o = 0;
				case (lsu_size_i)
					3'd0 :
							case (lsu_addr_i[1:0])
								2'b00 : 
									begin
										lsu_data_o = {{24{data_rdata_i[7]}}, data_rdata_i[7:0]};
									end
								2'b01 : 
									begin
										lsu_data_o = {{24{data_rdata_i[15]}}, data_rdata_i[15:8]};
									end
								2'b10 : 
									begin
										lsu_data_o = {{24{data_rdata_i[23]}}, data_rdata_i[23:16]};
									end
								2'b11 : 
									begin
										lsu_data_o = {{24{data_rdata_i[31]}}, data_rdata_i[31:24]};
									end
							endcase
						
					3'd1:
					
						case (lsu_addr_i[1:0])
								2'b00 : 
									begin
										lsu_data_o = {{16{data_rdata_i[15]}}, data_rdata_i[15:0]};
									end
								2'b10 : 
									begin
										lsu_data_o = {{16{data_rdata_i[31]}}, data_rdata_i[31:16]};
									end
						endcase
					
					3'd2:
					
						if (lsu_addr_i[1:0] == 2'b00)
							lsu_data_o = data_rdata_i;
					
					3'd4:
						
							case (lsu_addr_i[1:0])
									2'b00 : 
										begin
											lsu_data_o = {24'b0, data_rdata_i[7:0]};
										end
									2'b01 : 
										begin
											lsu_data_o = {24'b0, data_rdata_i[15:8]};
										end
									2'b10 : 
										begin
											lsu_data_o = {24'b0, data_rdata_i[23:16]};
										end
									2'b11 : 
										begin
											lsu_data_o = {24'b0, data_rdata_i[31:24]};
										end
								
							endcase
						
					3'd5:
						
						case (lsu_addr_i[1:0])
								2'b00 : 
									begin
										lsu_data_o = {16'b0, data_rdata_i[15:0]};
									end
								2'b10 : 
									begin
										lsu_data_o = {16'b0, data_rdata_i[31:16]};
									end
						endcase
					
			endcase
		end
end



endmodule