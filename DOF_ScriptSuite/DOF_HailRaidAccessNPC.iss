function main()
{    
	switch ${Zone.Name}
	{
		case The Sinking Sands
			if ${Math.Distance[${Actor[${Me.ID}].Loc},-358.49,-143.14,-1052.72]} < 9
			{
				ogreBotAPI:Message[${Me.Name}, >>>>Hailing Gates NPC for access<<<<, TRUE, default]
				
				Actor[exactname,"Muleek Mahaja"]:DoTarget
				wait 10
				EQ2Execute /hail
				
				wait 10
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick
				
				wait 10
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick
				
				wait 10
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick
				
				wait 10
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick
				
				wait 10
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick

			}
		break
		
		case The Pillars of Flame
			if ${Math.Distance[${Actor[${Me.ID}].Loc},896.49,-168.20,-1579.84]} < 9
			{
				ogreBotAPI:Message[${Me.Name}, >>>>Hailing Court NPC for access<<<<, TRUE, default]

				Actor[exactname,"Walheed Raffini"]:DoTarget
				wait 10
				EQ2Execute /hail
				
				wait 10
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick
				
				wait 10
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick
				
				wait 10
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick
				
				wait 10
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick
				
				wait 10
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick
				
				wait 10
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick
			}
		break
	}
}