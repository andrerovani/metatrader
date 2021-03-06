//+------------------------------------------------------------------+
//|                                                       simple.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, André Zanin Rovani"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

const int periodo_media = 9;
int OnInit()
{
	ChartSetInteger(0,CHART_SHOW_GRID,false);
	return INIT_SUCCEEDED;
}
void OnDeinit(const int reason)
{
}
int tick_count = 0;
void OnTick()
{
	tick_count++;

	if(Bars<=periodo_media)
		return;
		
	bool newbar = false;
	static datetime time = Time[0];
	if(Time[0] > time)
	{
		time = Time[0]; //newbar, update time
		newbar = true;
	} 		

	if(newbar)
	{
	double ma0 = iMA(NULL,0,periodo_media,0,MODE_SMA,PRICE_CLOSE,0);
   double ma1 = iMA(NULL,0,periodo_media,0,MODE_SMA,PRICE_CLOSE,1);
   double ma2 = iMA(NULL,0,periodo_media,0,MODE_SMA,PRICE_CLOSE,2);
	
	const int num_tendencia = 8;
	if(Close[1]>ma1 && Close[2]<ma2) // se o preco cruzou para cima da media
	{
		bool armado = true;
		for(int i=2; i<num_tendencia; i++)
		{
			if(Close[i]> iMA(NULL,0,periodo_media,0,MODE_SMA,PRICE_CLOSE,i))
			{
				Print("Setup desarmado.");
				armado = false;
				break;
			}
		}
		if(armado)
			draw_trade("compra"+tick_count, false);
	}
	
	if(Close[1]<ma1 && Close[2]>ma2) // se o preco cruzou para baixo da media
	{
		bool armado = true;
		for(int i=2; i<num_tendencia; i++)
		{
			if(Close[i]< iMA(NULL,0,periodo_media,0,MODE_SMA,PRICE_CLOSE,i))
			{
				Print("Setup desarmado.");
				armado = false;
				break;
			}
		}
		if(armado)
			draw_trade("venda"+tick_count, true);
	}
	}
	else
	{
		Print("Barra antiga.");
	}
}

void draw_trade(string name, bool venda)
{
	Print("desenhando trade...");
	datetime now = TimeCurrent();
	color vermelho  = C'225,68,29';
	color azul = C'3,95,172';
	color cor;
	int figura;
	double preco;
	int ancora;
	if(venda)
	{
		cor = vermelho;
		figura = OBJ_ARROW_DOWN;
		preco = Low[1];
		ancora = ANCHOR_BOTTOM;
		//ancora = ANCHOR_TOP;
	}
	else
	{
		cor = azul;
		figura = OBJ_ARROW_UP;
		preco = High[1];
		ancora = ANCHOR_TOP;
	}
	
    if(ObjectFind(name)  < 0)
        ObjectCreate(name, figura, 0, now, preco);

	ObjectSetInteger(0, name, OBJPROP_ANCHOR, ancora); 
  	ObjectSetInteger(0, name, OBJPROP_COLOR, cor); 	
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);//--- set a line style (when highlighted)  	 
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 3);//--- set a line size (when highlighted) 	
   ObjectSetInteger(0, name, OBJPROP_BACK, false);//--- display in the foreground (false) or background (true)  	 
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);//--- enable (true) or disable (false) the mode of moving the sign by mouse 
   ObjectSetInteger(0, name, OBJPROP_SELECTED ,false);  
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true); //--- hide (true) or display (false) graphical object name in the object list
}

