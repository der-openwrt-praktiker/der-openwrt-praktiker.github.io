#!/bin/sh

AUTHKEY=12345678901234567890
ENCKEY=123456789012345678901234

ip xfrm state flush
ip xfrm policy flush

# OSPFv2 Hello-Pakete an alle OSPF-(Designated-)Router
ip xfrm state add src 0.0.0.0 dst 224.0.0.5 proto esp spi 0x10003 mode transport reqid 0 auth "hmac(sha1)" $AUTHKEY enc "cbc(aes)" $ENCKEY sel src 0.0.0.0/0 dst 0.0.0.0/0
ip xfrm state add src 0.0.0.0 dst 224.0.0.6 proto esp spi 0x10004 mode transport reqid 0 auth "hmac(sha1)" $AUTHKEY enc "cbc(aes)" $ENCKEY sel src 0.0.0.0/0 dst 0.0.0.0/0

ip xfrm policy add src 0.0.0.0/0 dst 224.0.0.5/32 dir in  tmpl src 0.0.0.0 dst 0.0.0.0 proto esp mode transport
ip xfrm policy add src 0.0.0.0/0 dst 224.0.0.5/32 dir out tmpl src 0.0.0.0 dst 0.0.0.0 proto esp mode transport
ip xfrm policy add src 0.0.0.0/0 dst 224.0.0.6/32 dir in  tmpl src 0.0.0.0 dst 0.0.0.0 proto esp mode transport
ip xfrm policy add src 0.0.0.0/0 dst 224.0.0.6/32 dir out tmpl src 0.0.0.0 dst 0.0.0.0 proto esp mode transport


# OSPFv3 Hello-Pakete an alle OSPF-(Designated-)Router
ip xfrm state add src ::/0 dst ff02::5 proto esp spi 0x10003 mode transport reqid 0 auth "hmac(sha1)" $AUTHKEY enc "cbc(aes)" $ENCKEY sel src ::/0 dst ::/0
ip xfrm state add src ::/0 dst ff02::6 proto esp spi 0x10004 mode transport reqid 0 auth "hmac(sha1)" $AUTHKEY enc "cbc(aes)" $ENCKEY sel src ::/0 dst ::/0

ip xfrm policy add src ::/0 dst ff02::5 dir in  tmpl src ::/0 dst ::/0 proto esp mode transport
ip xfrm policy add src ::/0 dst ff02::5 dir out tmpl src ::/0 dst ::/0 proto esp mode transport
ip xfrm policy add src ::/0 dst ff02::6 dir in  tmpl src ::/0 dst ::/0 proto esp mode transport
ip xfrm policy add src ::/0 dst ff02::6 dir out tmpl src ::/0 dst ::/0 proto esp mode transport
