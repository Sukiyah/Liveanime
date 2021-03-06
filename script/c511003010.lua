--超融合
function c511003010.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e0)
	e1:SetCost(c511003010.cost)
	e1:SetTarget(c511003010.target)
	e1:SetOperation(c511003010.activate)
	c:RegisterEffect(e1)
end
function c511003010.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
function c511003010.filter0(c,e,tp,mg)
	return mg:IsExists(c511003010.filter1,1,c,e,tp,c)
end
function c511003010.filter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return Duel.IsExistingMatchingCard(c511003010.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
end
function c511003010.filter2(c,e,tp,mg)
	if not mg:IsExists(function(c) return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or (c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)) end,1,nil) then
		return false end 
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg,nil)
end
function c511003010.mfilter(c)
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER
end
function c511003010.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		local g=Duel.GetMatchingGroup(c511003010.mfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESET_MSCHANGE)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		local mg2=Duel.GetFusionMaterial(1-tp):Filter(Card.IsOnField,nil)
		mg1:Merge(mg2)
		local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and mg:IsExists(c511003010.filter0,1,nil,e,tp,mg1)
		tc=g:GetFirst()
		while tc do
			tc:ResetEffect(RESET_MSCHANGE,RESET_EVENT)
			tc=g:GetNext()
		end
		return check
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function c511003010.filter3(c,e,tp,mg)
	return not c:IsImmuneToEffect(e) and mg:IsExists(c511003010.filter4,1,c,e,tp,c)
end
function c511003010.filter4(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return not c:IsImmuneToEffect(e) and Duel.IsExistingMatchingCard(c511003010.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
end
function c511003010.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<-1 then return end
	local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
	local g=Duel.GetMatchingGroup(c511003010.mfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	local tc=g:GetFirst()
	while tc do
	local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_CHAIN)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
	local mg2=Duel.GetFusionMaterial(1-tp):Filter(Card.IsOnField,nil)	
	mg1:Merge(mg2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g1=mg:FilterSelect(tp,c511003010.filter3,1,1,nil,e,tp,mg1)
	if g1:GetCount()==0 then return end
	local tc1=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g2=mg1:FilterSelect(tp,c511003010.filter4,1,1,tc1,e,tp,tc1)
	g1:Merge(g2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,c511003010.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g1)
	local tc=sg:GetFirst()
	tc:SetMaterial(g1)
	Duel.SendtoGrave(g1,REASON_MATERIAL+REASON_FUSION+REASON_EFFECT)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c511003010.sumsuc)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	tc:RegisterEffect(e1,true)
end
function c511003010.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end
