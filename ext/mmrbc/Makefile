CC = gcc
TARGET = libparse.so
PARSE = parse
CRC = crc

all: libparse.so libcrc.so

libparse.so: $(PARSE).c
	$(CC) -std=c99 -Wall -c -fPIC $(OPT) -o $(PARSE).o $(PARSE).c
	$(CC) -shared -o $(TARGET) $(PARSE).o

$(PARSE).c: lemon
	../../vendor/lemon/lemon -p ./$(PARSE).y

lemon:
	cd ../../vendor/lemon ; $(MAKE) all

libcrc.so: $(CRC).c
	$(CC) -c -fPIC $(OPT) -o $(CRC).o $(CRC).c
	$(CC) -shared -o lib$(CRC).so $(CRC).o

clean:
	cd ../../vendor/lemon ; $(MAKE) clean
	rm -f $(PARSE).c $(TARGET) $(PARSE).h $(PARSE).out $(PARSE).o lib$(CRC).so $(CRC).o
